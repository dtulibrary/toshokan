require 'uuidtools'

class OrdersController < ApplicationController
  
  before_filter :disable_header_searchbar

  # Delivery is called from DocDel
  skip_before_filter :authenticate, :only => [:delivery]

  protect_from_forgery :except => [:receipt]

  # TODO:
  # - HTTP 409 (Conflict) should report why there is a conflict
  # - Make more user friendly error screens
  # - Put more of the logic into model objects where appropriate

  def index
    not_found unless can? :view, Order

    # Only show orders where delivery has been requested.
    # This is done to filter "dead" orders from the result.
    # Dead orders can occur when user goes back in the order flow
    # and refreshes a page in the flow that lies before the order
    # enters the database.
    @orders = Order.where('delivery_status is not null').order('created_at desc')

    unless can? :view_any, Order
      @orders = @orders.where 'user_id = ?', current_user.id
    end

    # Translate query and facet fields to valid model fields/functions
    sql_map = {
      :date      => 'date(created_at)',
      :q_email   => 'email',
      :q_orderid => 'id',
    }

    sql_operator_map = {
      :q_orderid => '=',
    }

    # Translate certain query params to the form used in the model
    value_mappers = {}

    value_mappers[:q_orderid] = lambda do |v| 
      # Either match a full DIBS order id like F00001234
      %r{^#{Orders.order_id_prefix.downcase}0*(\d+)$}.match(v.downcase).try(:[], 1) ||
      # or a DB id like 1234
      /^(\d+)$/.match(v).try(:[], 1)
    end

    # Apply query params.
    # Don't wrap value in "%...%" for values returned by a value mapper.
    [:q_email, :q_orderid].each do |q|
      if params[q] && !params[q].blank?
        value = params[q].strip
        @orders = @orders.where "#{sql_map[q] || q} #{sql_operator_map[q] || 'LIKE'} ?", 
                                value_mappers[q].try(:call, value) || "%#{value}%"
      end
    end

    @filter_queries = {}

    # Apply filter queries
    [:email, :date].each do |facet|
      if params[facet] && !params[facet].blank?
        @orders = @orders.where "#{sql_map[facet] || facet} = ?", params[facet]
        @filter_queries[facet] = params[facet]
      end
    end

    # Create facets
    @facets = {
      :email => @orders.group('email').reorder('email asc').count,
      :date  => @orders.select('date(created_at)').group('date(created_at)').reorder('date(created_at) desc').limit(30).count
    }

    # Reject facets that have 1 or less values and are not selected
    @facets.reject! {|k,v| v.size < 2 && !v.keys.include?(params[k])}

    @orders         = @orders.page(params[:page] || 1).per(50)
    @display_order  = @orders.collect {|o| o.created_at.to_date}.uniq
    @orders_by_date = {}

    # Group orders by date
    @orders.each do |order|
      date = order.created_at.to_date
      @orders_by_date[date] ||= []
      @orders_by_date[date] << order
    end
  end

  # Create a new order based on URL parameters "open_url" and "supplier"
  def new 
    # User might have logged in or out on any of the order creation pages
    # Reset order creation to reflect price based on new user type
    if session[:order] && !params[:open_url] && !params[:supplier]
      order = session[:order]

      # Only reset order if status fields allow it
      if order.payment_status || order.delivery_status
        head :conflict
      else
        params[:open_url] = order.open_url
        params[:supplier] = order.supplier
        order.delete
        session.delete :order
      end
    end

    # Create new order based on params - any existing order in session will be overwritten.
    if params[:open_url] && params[:supplier]
      @open_url = params[:open_url]
      @supplier = params[:supplier].to_sym
      logger.debug "setting return_url :#{session[:order_return_url]}"

      price = PayIt::Prices.price current_user, @supplier, :DKK
      @order = Order.new({
        :uuid => UUIDTools::UUID.timestamp_create.to_s,
        :open_url => @open_url, 
        :supplier => @supplier, 
        :price => price,
        :vat => PayIt::Prices.vat(price),
        :currency => :DKK
      })
      @order.user = current_user if current_user.authenticated?
      @order.flow = OrderFlow.new current_user, @supplier
      session[:order] = @order

      # Tell user about benefits of logging in
      # flash.now[:notice] = I18n.t 'toshokan.orders.not_logged_in_notice' unless current_user.authenticated?
    else
      head :bad_request
    end
  end

  def create 
    if session[:order]
      # Update order in session
      @order = session[:order]

      if @order.new_record?
        # Order has been created in session and needs information before going into database.
        errors = find_errors @order, params

        if errors.empty?
          # Update order and send user to confirmation page
          params_to_order @order
          @order.save!
          @order.flow.current_step = :confirm
          render :confirm
        else
          flash_errors errors
          @order.flow.current_step = :delivery_info
          render :new
        end
      elsif !@order.payment_status && !@order.delivery_status
        # Order has been created in database, but it has not been paid or asked for delivery yet.
        # There are several reasons for being here:
        # - User reloaded the confirmation page
        # - User clicked 'back' on the confirmation page to edit delivery information
        # - User clicked browser back on the confirmation and submitted delivery information form again

        case params[:button]
        when 'continue'
          # This is a reload of order confirmation or a submit of delivery information
          errors = find_errors @order, params

          if errors.empty?
            params_to_order @order
            @order.save!
            @order.flow.current_step = :confirm
            render :confirm
          else
            @order = renew_order @order
            
            flash_errors errors
            render :new and return
          end
        when 'back'
          # This is click on "back" on the order confirmation page
          order_to_params @order
          @order = renew_order @order

          render :new
        else
          head :bad_request
        end
      else
        # Error: The order is in a state where it can't be modified anymore (payment and/or delivery has been requested).
        #        This error should never be seen unless user tampers with order id's and such.

        head :conflict
      end
    else
      # Error: missing session values
      head :bad_request
    end
  end

  # Remove the order from the database and reset it to be in a state suitable for
  # the delivery information page.
  # NOTE: Deleting the order from the database freezes its activerecord hash so
  #       we duplicate the order and update the session and instance variable
  #       with the new order object.
  def renew_order order
    new_order = order.dup
    new_order.email = nil
    new_order.mobile = nil
    new_order.customer_ref = nil
    new_order.flow.current_step = :delivery_info
    session[:order] = new_order
    
    order.delete if order.persisted?
    new_order
  end

  # Update order with values from params
  def params_to_order order, local_params = params
    order.email = local_params[:email] unless local_params[:email].blank?
    order.mobile = local_params[:mobile] unless local_params[:mobile].blank?
    order.customer_ref = local_params[:customer_ref] unless local_params[:customer_ref].blank?
  end

  # Update params with values from order
  def order_to_params order, local_params = params
    local_params[:email] = order.email
    local_params[:email_confirmation] = order.email
    local_params[:mobile] = order.mobile
    local_params[:customer_ref] = order.customer_ref
    local_params[:terms_accepted] = false
  end

  # Find errors in params
  # TODO: Maybe should be put into activerecord validations instead
  def find_errors order, local_params = params
    errors = {}
    errors[:email] = I18n.t('toshokan.orders.errors.email_should_not_be_blank') if order.flow.fields.include?(:email) && local_params[:email].blank?
    errors[:email_confirm] = I18n.t('toshokan.orders.errors.emails_dont_match') if order.flow.fields.include?(:email) && local_params[:email] != local_params[:email_confirmation]
    errors[:terms_accepted] = I18n.t('toshokan.orders.errors.you_must_accept_terms') if order.flow.fields.include?(:terms_accepted) && !local_params[:terms_accepted]
    errors
  end

  def flash_errors errors
    flash.now[:error] = []
    errors.each do |k,v|
      flash.now[:error] << v
    end
  end

  # Will be called by DIBS upon user cancelling payment
  def cancel
    @order = Order.find_by_uuid params[:uuid]

    @order.flow = OrderFlow.new current_user, @order.supplier
    @order.flow.current_step = :done

    if !@order.payment_status
      @order.payment_status = :cancelled
      @order.delivery_status = :cancelled
      @order.order_events << OrderEvent.new(:name => :payment_cancelled)
      @order.save!
      session.delete :order
    else
      logger.error "Order with id #{@order.id} had wrong payment status '#{@order.payment_status}' when trying to cancel it"
    end
  end

  # Will be called by DIBS upon entering valid credit card info. 
  # Will be redirected to by DIBS when user goes to receipt.
  # Will be redirected to for non-payment orders.
  def receipt
    session.delete :order

    @order = Order.find_by_uuid params[:uuid]
  
    @order.flow = OrderFlow.new current_user, @order.supplier
    @order.flow.current_step = :done

    @order_status_url = order_status_url :uuid => @order.uuid

    if @order.flow.steps.include?(:payment) && !@order.payment_status
      case PayIt::Dibs.status_code params[:statuscode]
      when :declined
      when :declined_by_dibs
      when :authorization_approved
        if PayIt::Dibs.authentic? params.merge(:amount => (@order.price + @order.vat), :currency => @order.currency)
          @order.payment_status = :authorized
          @order.dibs_transaction_id = params[:transact]
          @order.masked_card_number = params[:cardnomask]
          @order.order_events << OrderEvent.new(:name => :payment_authorized, :data => params[:cardnomask])
          @order.save!
        else
          head :bad_request and return
        end
      else
      end
    end
    
    # Ensure idempotency
    unless @order.delivery_status
      @order.order_events << OrderEvent.new(:name => :delivery_requested)
      @order.delivery_status = :initiated
      @order.save!

      DocDel.delay.request_delivery @order, order_delivery_url(@order.uuid), :timecap_base => Time.now.iso8601 if DocDel.enabled?
      SendIt.delay.send_confirmation_mail @order, :order => {:status_url => order_status_url(@order.uuid)}
    end
  end

  # Will be called by DocDel upon document delivery or document unavailable
  def delivery
    @order = Order.find_by_uuid params[:uuid]
    delivery_status = params[:status].to_sym

    if [:deliver, :confirm, :cancel].include? delivery_status
      case delivery_status
      when :deliver
        logger.error "No 'url' parameter on delivery event for order #{@order.dibs_order_id}" unless params[:url]
        is_redelivery = [:reordered, :redelivery_requested].include? @order.delivery_status

        @order.order_events << OrderEvent.new(:name => is_redelivery ? 'redelivery_done' : 'delivery_done', :data => params[:url])
        @order.delivery_status = delivery_status
        @order.delivered_at = Time.now
        @order.save!
        
        SendIt.delay.send_delivery_mail @order, :url => params[:url], :order => {:status_url => order_status_url(@order.uuid)}
        
        # Do not send receipt mails to DTU staff or when order has been reordered
        unless (@order.user && @order.user.employee?) || is_redelivery
          SendIt.delay.send_receipt_mail @order, :order => {:status_url => order_status_url(@order.uuid)}
        end

        # Only capture amounts for orders that were paid for and that weren't reordered
        PayIt::Dibs.delay.capture @order if @order.payment_status && !is_redelivery

      when :confirm
        if @order.delivery_status == :reordered
          @order.order_events << OrderEvent.new(:name => 'reorder_confirmed')
        else
          @order.order_events << OrderEvent.new(:name => 'delivery_confirmed')
        end
        @order.supplier_order_id = params[:supplier_order_id] if params[:supplier_order_id]
        @order.save!

      when :cancel
        # Only cancel in DIBS if order was paid for
        PayIt::Dibs.delay.cancel @order if @order.payment_status
        @order.delivery_status = :cancelled

        if @order.user && (@order.user.employee? || @order.user.student?)
          @order.order_events << OrderEvent.new(:name => 'delivery_manual')

          # Send mail to delivery support 
          SendIt.delay.send_failed_automatic_request_mail @order, params[:reason]
        else
          @order.order_events << OrderEvent.new(:name => 'delivery_cancelled')
          SendIt.delay.send_cancellation_mail @order, :order => {:status_url => order_status_url(@order.uuid)}
        end

        @order.save!
      end

      head :ok
    else
      render :text => "Unknown delivery status: '#{delivery_status}'.\nShould be one of \"deliver\", \"confirm\" or \"cancel\".", :layout => nil, :status => :bad_request
    end

  end

  def status
    @order = Order.find_by_uuid params[:uuid]
    @restricted_events = ['payment_authorized', 'reordered', 'reorder_confirmed']
  end

  def reorder
    order = Order.find_by_uuid params[:uuid]

    if can?(:reorder, Order) && !order.cancelled?
      if order
        DocDel.delay.request_delivery order, order_delivery_url(order.uuid), :timecap_base => Time.now.iso8601 if DocDel.enabled?
        order.delivery_status = :reordered      
        order.order_events << OrderEvent.new(:name => 'reordered', :data => current_user.to_s)
        order.save!
        flash[:notice] = I18n.t 'toshokan.orders.flash_messages.reordered'
      else
        flash[:error] = I18n.t 'toshokan.orders.flash_messages.error_reordering'
      end
    end

    redirect_to order_status_path order.uuid
  end
end
