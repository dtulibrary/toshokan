require 'library_support'

class AssistanceRequestsController < ApplicationController

  include Toshokan::PerformsSearches
  include Toshokan::Resolver


  def index
    if can? :request, :assistance
      if can? :view, :all_assistance_requests
        @assistance_requests = AssistanceRequest.all
      elsif can? :view, :own_assistance_requests
        @assistance_requests = AssistanceRequest.find_by_user_id current_user.id
      else
        head :not_found
      end
    else
      head :not_found
    end
  end

  def new
    if can? :request, :assistance
      if params[:record_id]
        begin
          response, document = get_solr_response_for_doc_id(params[:record_id])
          @genre = determine_assistance_request_genre(document)
          head :not_found and return unless @genre
          params.merge! :assistance_request => document_to_assistance_request_params(document, @genre), :genre => @genre
          @assistance_request = assistance_request_from(params)
        rescue Blacklight::Exceptions::InvalidSolrID
          logger.debug "Document with cluster id #{params[:record_id]} not found"
          head :not_found and return
        end
      elsif params[:genre]
        @genre              = genre_from(params)
        @assistance_request = assistance_request_from(params) || assistance_request_for(@genre)
        head :bad_argument and return unless @assistance_request
      else
        head :bad_request
      end
    else
      render 'cant_request_assistance'
    end
  end

  def create
    if can? :request, :assistance
      genre = genre_from params

      if genre
        assistance_request = assistance_request_from params

        if assistance_request
          assistance_request.user = current_user
          assistance_request.email = current_user.email

          action = params[:button] || :create

          case action.to_sym
          when :confirm
            if assistance_request.valid?
              assistance_request.save!

              order = Order.new
              order.user = assistance_request.user
              order.assistance_request_id = assistance_request.id
              order.created_at = assistance_request.created_at
              order_updated_at = assistance_request.updated_at
              order.supplier = :dtu_manual
              order.price = 0
              order.vat = 0
              order.currency = :DKK
              order.email = assistance_request.email
              order.uuid = UUIDTools::UUID.timestamp_create.to_s
              order.open_url = assistance_request.openurl.kev
              order.org_unit = assistance_request.user.user_data["dtu"]["org_units"].first if assistance_request.user.dtu?
              order.delivery_status = :initiated
              order.order_events << OrderEvent.new(:name => 'request_manual', :data => assistance_request.id)
              order.save!

              if assistance_request.is_a?(PatentAssistanceRequest)
                SendIt.delay.send_patent_request(assistance_request)
                flash[:notice] = "Your request was sent to DTU PatLib"
              else
                LibrarySupport.delay.submit_assistance_request current_user, assistance_request, assistance_request_url(:id => assistance_request.id)
                SendIt.delay.send_book_suggestion current_user, assistance_request if assistance_request.book_suggest
                flash[:notice] = 'Your request was sent to a librarian'
              end
              redirect_to order_status_path(:uuid => order.uuid)
            else
              flash[:error] = assistance_request.errors
              redirect_to new_assistance_request_path(assistance_request)
            end
          else
            @genre = genre
            @assistance_request = assistance_request

            if assistance_request.valid?
              unless action == :back
                Rails.logger.info "CFF request"
                if params[:resolved]
                  Rails.logger.info "CFF ignored resolver results"
                else
                  # make resolver lookup
                  openurl = assistance_request.openurl
                  (count, response, document) = get_resolver_result(openurl.to_hash)
                  Rails.logger.info "CFF #{count} resolver results"
                  if count > 0
                    # redirect to resolver controller with assistance request params
                    openurl_str = openurl.kev
                    openurl_str.slice!(/&ctx_tim=[^&]*/)
                    redirect_to resolve_path + "?#{openurl_str}&#{{'assistance_request' => params['assistance_request']}.to_query}&assistance_genre=#{params["genre"]}" and return
                  end
                end
              end
            else
              flash.now[:error] = 'One or more required fields are empty'
              params.delete :button
              render :new
            end
          end
        else
          head :bad_request
        end
      else
        head :bad_request
      end
    else
      head :not_found
    end
  end

  def resend
    if can? :resend, LibrarySupport
      if AssistanceRequest.exists? params[:id]
        assistance_request = AssistanceRequest.find params[:id]
        LibrarySupport.delay.submit_assistance_request assistance_request.user, assistance_request, assistance_request_url(assistance_request), true
        SendIt.delay.send_book_suggestion assistance_request.user, assistance_request if assistance_request.book_suggest
        flash[:notice] = 'The request was resent to a librarian.'
        redirect_to assistance_request_path(assistance_request)
      else
        head :not_found
      end
    else
      head :not_found
    end
  end

  def genre_from(params)
    params[:genre].to_sym if params[:genre]
  end

  def determine_assistance_request_genre(document)
    # No CFF for journals
    return if document['format'] == 'journal'
    # No CFF for printed and electronic books (unspecified books have CFF)
    return if document['format'] == 'book' && ['printed', 'ebook'].include?(document['subformat_s'])
    # No pre-populated CFF for journal articles
    return if document['format'] == 'article' && document['subformat_s'] == 'journal_article'

    return :thesis if document['format'] == 'thesis'

    if document.has_key?('subformat_s')
      case document['subformat_s']
      when 'report'
        :report
      when 'standard'
        :standard
      when 'patent'
        :patent
      when 'journal_article'
        :journal_article
      when 'conference_paper'
        :conference_article
      else
        :other
      end
    else
      case document['format']
      when 'article'
        :journal_article
      when 'book'
        :book
      when 'other'
        :other
      end
    end
  end

  # Returns a proc that will get the contents of a doc field or return '?'
  # Used to populate required fields
  # TODO: This is the easy solution. Would be nice if required fields
  #       were turned off when populating from a record but that requires
  #       changes to the model validations and stuff on the lower levels.
  def required_field_proc(doc_field)
    -> { (doc_field.is_a?(Array) ? doc_field.first : doc_field) || '?' }
  end

  def document_to_assistance_request_params(document, genre)
    logger.debug "Document is #{document}"

    assistance_request_params = 
      case genre
      when :conference_article
        { 'article_title'    => required_field_proc(document['title_ts']),
          'article_author'   => 'author_ts',
          'article_doi'      => 'doi_ss',
          'conference_title' => required_field_proc(document['conf_title_ts'] || document['journal_title_ts']),
          'conference_isxn'  => -> { (document['issn_ss'] || document['isbn_ss'] || []).join(',') },
          'conference_year'  => required_field_proc(document['pub_date_tis']),
          'conference_pages' => required_field_proc(document['journal_page_ssf']) }
      when :thesis
        { 'thesis_title'     => required_field_proc(document['title_ts']),
          'thesis_author'    => required_field_proc(document['author_ts']),
          'thesis_publisher' => 'publisher_ts',
          'thesis_type'      => -> { subformat_to_thesis_type(document['subformat_s']) },
          'thesis_year'      => required_field_proc(document['pub_date_tis']),
          'thesis_pages'     => 'journal_page_ssf' }
      when :report
        { 'report_title'     => required_field_proc(document['title_ts']),
          'report_author'    => 'author_ts',
          'report_publisher' => 'publisher_ts',
          'report_doi'       => 'doi_ss',
          'host_title'       => 'journal_title_ts',
          'host_isxn'        => -> { (document['issn_ss'] || document['isbn_ss'] || []).join(',') },
          'host_volume'      => 'journal_vol_ssf',
          'host_issue'       => 'journal_issue_ssf',
          'host_year'        => required_field_proc(document['pub_date_tis']),
          'host_pages'       => 'journal_page_ssf' }
      when :standard
        { 'standard_title'     => required_field_proc(document['title_ts']),
          'standard_subtitle'  => 'subtitle_ts',
          'standard_publisher' => 'publisher_ts',
          'standard_doi'       => 'doi_ss',
          'standard_isbn'      => -> { (document['isbn_ss'] || []).join(',') },
          'standard_year'      => required_field_proc(document['pub_date_tis']),
          'standard_pages'     => 'journal_page_ssf' }
      when :patent
        { 'patent_title'    => 'title_ts',
          'patent_inventor' => 'author_ts',
          'patent_year'     => required_field_proc(document['pub_date_tis']),
          'patent_country'  => 'publication_place_ts' }
      when :other
        { 'other_title'     => required_field_proc(document['title_ts']),
          'other_author'    => 'author_ts',
          'other_publisher' => 'publisher_ts',
          'other_doi'       => 'doi_ss',
          'host_title'      => 'journal_title_ts',
          'host_isxn'       => -> { (document['issn_ss'] || document['isbn_ss'] || []).join(',') },
          'host_volume'     => 'journal_vol_ssf',
          'host_issue'      => 'journal_issue_ssf',
          'host_year'       => required_field_proc(document['pub_date_tis']),
          'host_pages'      => 'journal_page_ssf' }
      else
        {}
      end
      
    logger.debug "Assistance request params is #{assistance_request_params}"

    result = {}

    assistance_request_params.each do |ar_field, doc_field|
      if doc_field.is_a?(Proc)
        result[ar_field] = doc_field.()
      else
        result[ar_field] = document[doc_field].is_a?(Array) ? document[doc_field].try(:first) : document[doc_field]
      end
    end

    logger.debug "Assistance request is #{result}"
    result
  end

  def subformat_to_thesis_type(subformat)
    subformat
  end

  def assistance_request_from params
    type = Module.const_get("#{params[:genre]}_assistance_request".classify)
    type.new params_for_assistance_request(type)
  end

  def assistance_request_for genre
    Module.const_get("#{params[:genre]}_assistance_request".classify).new
  end

  def params_for_assistance_request( assistance_request_class=AssistanceRequest )
    # Only trust the params listed by the class `fields` method
    params.fetch(:assistance_request, {}).permit( *assistance_request_class.fields )
    # params.fetch(:assistance_request, {}).permit! # <-- This would trust everything in params[:assistance_request]
  end

end
