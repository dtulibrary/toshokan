require 'httparty'
require 'pp'

class SendIt
  include Configured

  def self.send_mail template, params = {}
    if SendIt.test_mode?
      Rails.logger.info "Received request to send mail: template = #{template}, params = #{params}"
    else
      begin
        url = "#{SendIt.url}/send/#{template}"
        Rails.logger.info "Sending mail request to SendIt: URL = #{url}, template = #{template}, params = #{params}"

        default_params = {
          :from => 'noreply@dtic.dtu.dk'
        }
        default_params[:priority] = 'now' unless SendIt.delay_jobs?

        response = HTTParty.post url, {
          :body => default_params.deep_merge(params).to_json,
          :headers => { 'Content-Type' => 'application/json' }
        }

        unless response.code == 200
          Rails.logger.error "SendIt responded with HTTP #{response.code}"
          raise "Error communicating with SendIt"
        end
      rescue
        Rails.logger.error "Error sending mail: template = #{template}\n#{params}"
        raise
      end
    end
  end

  def self.send_patent_request assistance_request
    patent_info = {}
   
    [:title, :inventor, :number, :year, :country].each do |field|
      field_value = assistance_request.send("patent_#{field}")
      patent_info[field] = field_value unless field_value.blank?
    end

    send_mail 'patlib', {
      :to       => SendIt.patlib_mail,
      :reply_to => assistance_request.user.email,
      :cc       => assistance_request.user.email,
      :user     => assistance_request.user.to_s,
      :patent   => patent_info
    }
  end

  def self.send_order_mail template, order, params = {}
    send_mail template, {
      :to    => order.email,
      :from  => Orders.reply_to_email,
      :order => {
        :id             => order.dibs_order_id,
        :title          => order.document['title_ts'].first,
        :journal        => order.document['journal_title_ts'].first,
        :author         => order.document['author_ts'].first,
        :amount         => order.price,
        :vat            => order.vat,
        :currency       => order.currency,
        :customer_ref   => order.customer_ref,
        :total          => (order.price + order.vat),
        :vat_pct        => 25,
        :masked_card_no => order.masked_card_number,
        :drm            => order.drm?,
        :paid           => order.payment_status == :authorized,
        :supplier       => order.supplier,
      }
    }.deep_merge(params)
  end

  def self.send_confirmation_mail order, params = {}
    send_order_mail 'findit_confirmation', order, params
  end

  def self.send_cancellation_mail order, params = {}
    send_order_mail 'findit_cancellation', order, params
  end

  def self.send_receipt_mail order, params = {}
    send_order_mail 'findit_receipt', order, params
  end

  def self.send_delivery_mail order, params = {}
    send_order_mail 'findit_delivery', order, params
  end

  def self.send_book_suggestion user, assistance_request, params = {}
    if SendIt.book_suggest_mail.blank?
      Rails.logger.info "config.send_it.book_suggest_mail is missing or blank. Sending mail aborted."
      return
    end

    mail_params = {
      :to    => SendIt.book_suggest_mail,
      :from  => user.email,
      :book  => {},
      :notes => assistance_request.notes,
      :user  => {
        :name => user.to_s,
      }
    }

    [:title, :year, :author, :edition, :doi, :isbn, :publisher].each do |field|
      value = assistance_request.send "book_#{field}"
      mail_params[:book][field] = value unless value.blank?
    end

    mail_params[:user][:cwis]    = user.user_data["dtu"]["matrikel_id"] if user.dtu?
    mail_params[:user][:address] = user.user_data["address"] unless user.user_data["address"].blank?

    mail_params.deep_merge! params

    send_mail 'book_suggestion', mail_params
  end

  def self.send_failed_automatic_request_mail order, reason = nil
    local_params = {
      :to => SendIt.delivery_support_mail,
      :open_url => {},
      :user => {
        :name => "%s (CWIS: %s)" % [order.user.to_s, order.user.user_data['dtu']['matrikel_id']],
        :email => order.user.email
      }
    }

    local_params[:dtu_unit] = "Students" if order.user.student?
    local_params[:reason] = reason if reason

    supplier_map = {
      :dtu => 'DTU Library - local scan',
      :rd => 'Reprints Desk'
    }

    local_params[:failed_from] = supplier_map[order.supplier] if order.supplier

    order.open_url.scan /([^&=]+)=([^&]*)/ do |k,v|
      local_params[:open_url][k] = URI.unescape(v.gsub '+', '%20') if k.start_with? 'rft'
    end

    send_mail 'failed_automatic_requests', local_params
  end

  def self.send_feedback_email(user, params = {})
    local_params = params.merge(:to => SendIt.feedback_mail)
    local_params.merge!(
      case
      when user.walk_in?
        { :user_info => 'Walk-in user',
          :subject   => '[DTU Library] Feedback from walk-in user' }
      when user.authenticated?
        { :user_info => user.user_data.pretty_inspect,
          :subject   => '[DTU Library] Feedback from authenticated user' }
      else
        { :user_info => 'Public user - not logged in',
          :subject   => '[DTU Library] Feedback from public user' }
      end
    )

    send_mail('findit_feedback', local_params)
  end
end
