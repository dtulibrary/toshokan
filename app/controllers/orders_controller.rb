require 'uuidtools'

class OrdersController < ApplicationController
  
  before_filter :disable_header_searchbar

  # TODO:
  # - HTTP 409 (Conflict) should report why there is a conflict
  # - Make more user friendly error screens
  # - Put more of the logic into model objects where appropriate

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
      flash.now[:notice] = I18n.t 'toshokan.orders.not_logged_in_notice' unless current_user.authenticated?
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
        email = params[:email]
        email_confirmation = params[:email_confirmation]
        terms_accepted = params[:terms_accepted]

        errors = {}
        errors[:email] = I18n.t('toshokan.orders.errors.email_should_not_be_blank') if @order.flow.fields.include?(:email) && email.blank?
        errors[:email_confirm] = I18n.t('toshokan.orders.errors.emails_dont_match') if @order.flow.fields.include?(:email) && email != email_confirmation
        errors[:terms_accepted] = I18n.t('toshokan.orders.errors.you_must_accept_terms') if @order.flow.fields.include?(:terms_accepted) && !terms_accepted

        if errors.empty?
          # Update order and send user to confirmation page
          @order.email = email
          @order.mobile = params[:mobile]
          @order.customer_ref = params[:customer_ref]
          @order.save!

          @order.flow.continue

          case @order.flow.current_step
          when :confirm
            render :confirm
          else
            # TODO: Since everybody has to confirm their order this should never happen.
            #       Some sort of error should be shown.
            logger.error "Invalid order flow step: #{@order.flow.current_step} for order with id #{@order.id}"
            head :internal_server_error 
          end
        else
          # Form values missing or invalid. Show form with values and errors.
          flash.now[:error] = []
          errors.each do |k,v|
            flash.now[:error] << v
          end
          render :new
        end
      elsif !@order.payment_status && !@order.delivery_status
        # Order has been created in database, but it has not been paid or asked for delivery yet.
        # There are several reasons for being here:
        # - User reloaded the confirmation page
        # - User clicked 'back' on the confirmation page to edit delivery information

        # User reloaded the confirmation page - just show the confirm page again
        render :confirm and return if params[:button] == 'continue'

        # Populate params with values from saved order
        params[:email] = @order.email
        params[:email_confirmation] = @order.email
        params[:mobile] = @order.mobile
        params[:customer_ref] = @order.customer_ref
        params[:terms_accepted] = true

        # Remove the order from the database and reset it to be in a state suitable for
        # the delivery information page.
        # NOTE: Deleting the order from the database freezes its activerecord hash so
        #       we duplicate the order and update the session and instance variable
        #       with the new order object.
        new_order = @order.dup
        new_order.flow.back
        session[:order] = new_order

        @order.delete
        @order = new_order

        render :new
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

  # Will be called by DIBS upon user cancelling payment
  def cancel
    @order = Order.find_by_uuid params[:uuid]

    if !@order.payment_status
      @order.payment_status = :cancelled
      @order.order_events << OrderEvent.new(:name => :payment_cancelled)
      @order.save!
    else
      logger.error "Order with id #{@order.id} had wrong payment status '#{@order.payment_status}' when trying to cancel it"
    end
  end

  # Render a receipt upon successful order completion
  def receipt
    @order = Order.find_by_uuid params[:uuid]
  
    @order.flow = OrderFlow.new current_user, @order.supplier
    @order.flow.current_step = :done


    if @order.flow.steps.include?(:payment) && !@order.payment_status
      case PayIt::Dibs.status_code params[:statuscode]
      when :declined
      when :declined_by_dibs
      when :authorization_approved
        if PayIt::Dibs.authentic? params.merge(:amount => (@order.price + @order.vat), :currency => @order.currency)
          @order.payment_status = :authorized
          @order.dibs_transaction_id = params[:transact]
          @order.order_events << OrderEvent.new(:name => :payment_authorized)
          @order.save!
        else
          head :bad_request and return
        end
      else
      end
    end
    
    unless @order.delivery_status
      # Send request to DocDel in background
      DocDel.delay.request_delivery @order, order_delivery_url(@order.uuid)

      SendIt.delay.send_mail 'findit_confirmation', {
        :to => @order.email, 
        :from => Orders.reply_to_email,
        :order => {
          :id => @order.dibs_order_id,
          :title => @order.document['title_ts'],
          :journal => @order.document['journal_title_ts'],
          :authors => @order.document['author_ts'],
          :amount => @order.price,
          :vat => @order.vat,
          :total => (@order.price + @order.vat),
          :currency => @order.currency,
          :vat_pct => 25
        }
      }

      @order.order_events << OrderEvent.new(:name => :delivery_requested)
      @order.delivery_status = :initiated
      @order.save!
    end
  end

  # Will be called by DocDel upon document delivery or document unavailable
  def delivery
    @order = Order.find_by_uuid params[:uuid]
    delivery_status = params[:status].to_sym

    if [:deliver, :confirm, :cancel].include? delivery_status
      case delivery_status
      when :deliver
        @order.order_events << OrderEvent.new(:name => 'delivery_done')
        @order.delivery_status = delivery_status
        @order.delivered_at = Time.now

        # TODO: Update with correct fields and values when the template is actually created in SendIt
        SendIt.delay.send_mail 'findit_receipt', {
          :to => @order.email,
          :from => Orders.config.reply_to_email,
          :order => {
            :id => @order.dibs_order_id,
          }
        }

        PayIt::Dibs.delay.capture @order
      when :confirm
        @order.order_events << OrderEvent.new(:name => 'delivery_confirmed')
      when :cancel
        @order.order_events << OrderEvent.new(:name => 'delivery_cancelled')
      end
      @order.save!

      head :ok
    else
      render :text => "Unknown delivery status: '#{delivery_status}'.\nShould be one of \"deliver\", \"confirm\" or \"cancel\".", :layout => nil, :status => :bad_request
    end

  end

  def status
    @order = Order.find_by_uuid params[:uuid]
  end

end
