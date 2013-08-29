require 'httparty'

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

  def self.send_order_mail template, order, params = {}
    send_mail template, {
      :to => order.email,
      :from => Orders.reply_to_email,
      :order => {
        :id => order.dibs_order_id,
        :title => order.document['title_ts'].first,
        :journal => order.document['journal_title_ts'].first,
        :author => order.document['author_ts'].first,
        :amount => order.price,
        :vat => order.vat,
        :currency => order.currency,
        :customer_ref => order.customer_ref,
        :total => (order.price + order.vat),
        :vat_pct => 25,
        :masked_card_no => order.masked_card_number,
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

  def self.send_request_assistance_mail genre, user, params = {}
    case genre
    when :journal_article
      type = 'article'
      title = params[:article_title]
    when :conference_article
      type = 'conference_article'
      title = params[:article_title]
    when :book
      type = 'book'
      title = params[:book_title]
    else
      type = 'article'
      title = params[:article_title]
    end


    local_params = {
      :to => SendIt.delivery_support_mail,
      :type => type,
      :title => title,
      :user => {
        :email => user.email,
        :name => "#{user}#{user.dtu? ? " (CWIS: #{user.user_data['dtu']['matrikel_id']})" : ""}",
      }
    }

    local_params.deep_merge! article_params params
    local_params.deep_merge! journal_params params
    local_params.deep_merge! conference_params params
    local_params.deep_merge! proceedings_params params
    local_params.deep_merge! book_params params
    local_params.deep_merge! publisher_params params
    local_params.deep_merge! pickup_location_params params
    local_params.deep_merge! notes_params params

    send_mail 'library_assistance', local_params
  end

  def self.article_params params
    result = {}
    if params['article_title']
      result[:article] = extract_params ['article_title', 'author', 'doi'], params
    end
    result
  end

  def self.journal_params params
    result = {}
    if params['journal_title']
      result[:journal] = extract_params ['journal_title', 'issn', 'volume', 'issue', 'year', 'pages'], params
    end
    result
  end

  def self.conference_params params
    result = {}
    if params['conference_title']
      result[:conference] = extract_params ['conference_title', 'location', 'number', 'year'], params
    end
    result
  end

  def self.proceedings_params params
    result = {}
    if params['proceedings_title']
      result[:proceedings] = extract_params ['proceedings_title', 'isxn', 'pages'], params
    end
    result
  end

  def self.book_params params
    result = {}
    if params['book_title']
      result[:book] = extract_params ['book_title', 'author', 'edition', 'doi', 'isbn'], params
    end
    result
  end

  def self.publisher_params params
    result = {}
    if params['publisher_name']
      result[:publisher] = extract_params ['publisher_name'], params
    end
    result
  end

  def self.pickup_location_params params
    extract_params ['pickup_location'], params
  end

  def self.notes_params params
    extract_params ['notes'], params
  end

  def self.extract_params names, params
    result = {}
    names.each do |name|
      # XXX: Rename form parameters like 'article_title' or 'publisher_name' to 'title' and 'name'
      #      since they will appear in an object-style hash. 
      #      So 'article_title' will be in 'article' => { 'title' => ... }
      result[name.gsub /.*_(title|name)/, '\1'] = params[name] unless params[name].blank?
    end
    result
  end

  def self.send_article_assistance_mail user, params = {}
    send_request_assistance_mail :journal_article, user, params
  end
end
