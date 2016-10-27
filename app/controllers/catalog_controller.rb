# -*- encoding : utf-8 -*-
require 'blacklight/catalog'
require 'i18n'

class CatalogController < ApplicationController
  layout 'with_search_bar'

  include Blacklight::Catalog
  include Toshokan::Catalog

  before_filter :inject_last_query_into_params, only:[:show]

  configure_blacklight do |config|
    # Ensure I18n load paths are loaded
    Dir[Rails.root + 'config/locales/**/*.{rb,yml}'].each { |path| I18n.load_path << path }

    # Set resolver params
    config.resolver_params = {
      "mm" => "100%"
    }

    config.autocomplete_path = '/solr/metastore/suggest'
    # Add support for :limit field type. Used by ToC filters. See also LimitsHelper.
    config[:limit_fields] = {}
    class << config
      def add_limit_field(limit, options={})
        self[:limit_fields][limit] = options
      end
    end

    config.solr_path = 'toshokan'
    config.document_solr_path = 'toshokan_document'
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      :q => '*:*',
      :rows => 10
    }

    ## Default parameters to send on single-document requests to Solr. These
    ## settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
      :q => "{!raw f=#{SolrDocument.unique_key} v=$id}"
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    }

    # Set per page options
    config.per_page = [10, 20, 50]
    config.max_per_page = 500

    # solr field configuration for search results/index views
    config.index.title_field = 'title_ts'
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    config.show.title_field = 'title_ts'
    config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #config.add_facet_field 'format', :collapse => false
    # We overwrite facet methods to ensure only the documents with access are included in facet display
    config.add_facet_field 'fulltext_availability_ss', label: 'Online Access', helper_method: :online_access_facet_display, collapse: false, if: :show_online_access_facet?
    config.add_facet_field 'format', :collapse => false
    #config.add_facet_field 'subformat_s', :collapse => false
    config.add_facet_field 'pub_date_tis', :label => I18n.t('blacklight.search.fields.facet.pub_date_tsort'), :range => true
    config.add_facet_field 'author_facet', :limit => 20
    config.add_facet_field 'journal_title_facet', :limit => 20
    config.add_facet_field 'isolanguage_facet', :limit => 20

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'author_ts', :helper_method => :render_shortened_author_links
    config.add_index_field 'journal_title_ts', :format => ['article'], :helper_method => :render_journal_info_index
    config.add_index_field 'conf_title_ts', :format => ['article'], :helper_method => :render_conference_info_index, :suppressed_by => ['journal_title_ts']
    config.add_index_field 'pub_date_tis', :format => ['book']
    config.add_index_field 'journal_page_ssf', :format => ['book']
    config.add_index_field 'format', :helper_method => :render_type
    #config.add_index_field 'subformat_s', :helper_method => :render_subtype
    config.add_index_field 'doi_ss'
    config.add_index_field 'publisher_ts', :format => ['book', 'journal']
    config.add_index_field 'abstract_ts', :helper_method => :snip_abstract
    config.add_index_field 'issn_ss', :format => ['journal']
    config.add_index_field 'dissertation_date_ssf', :helper_method => :render_dissertation_date, :format => ['thesis']

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'subtitle_ts'
    config.add_show_field 'title_abbr_ts'
    config.add_show_field 'author_ts', :helper_method => :render_author_links
    config.add_show_field 'affiliation_ts', :format => ['book', 'article', 'thesis','other'], :helper_method => :render_affiliations
    config.add_show_field 'editor_ts', :helper_method => :render_editor_links
    config.add_show_field 'pub_date_tis', :format => ['book','thesis','other']
    config.add_show_field 'journal_page_ssf', :format => ['book']
    config.add_show_field 'journal_title_ts', :format => ['article','thesis','other'], :helper_method => :render_journal_info_show
    config.add_show_field 'conf_title_ts', :helper_method => :render_conference_info_show
    config.add_show_field 'format', :helper_method => :render_type
    #config.add_show_field 'subformat_s', :helper_method => :render_subtype
    config.add_show_field 'publisher_ts'
    config.add_show_field 'isbn_ss'
    config.add_show_field 'issn_ss'
    config.add_show_field 'doi_ss'
    config.add_show_field 'language_ss'
    config.add_show_field 'abstract_ts'
    config.add_show_field 'keywords_ts', :helper_method => :render_keyword_links
    config.add_show_field 'subformat_s', :helper_method => :render_subtype
    config.add_show_field 'udc_ss'
    config.add_show_field 'dissertation_date_ssf', :helper_method => :render_dissertation_date, :format => ['thesis']
    config.add_show_field 'supervisor_ts', :helper_method => :render_author_links
    config.add_show_field 'series_title_ts'
    config.add_show_field 'inventor_ts'
    config.add_show_field 'patent_number_ss'
    config.add_show_field 'journal_subtitle_ts'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field 'all_fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    config.add_search_field 'title' do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      #field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        :qf => '$title_qf',
        #:pf => '$title_pf'
      }
    end

    config.add_search_field 'author' do |field|
      #field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = {
        :qf => '$author_qf',
        #:pf => '$author_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.

    config.add_search_field 'numbers' do |field|
      field.include_in_simple_select = false
      field.solr_local_parameters = {
        :qf => '$numbers_qf'
      }
    end

    config.add_search_field 'journal_title' do |field|
      field.include_in_simple_select = false
      field.solr_local_parameters = {
        :qf => '$journal_title_qf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_tsort desc, journal_vol_tsort desc, journal_issue_tsort desc, journal_page_start_tsort asc, title_sort asc', :label => 'relevance'
    config.add_sort_field 'pub_date_tsort desc, journal_vol_tsort desc, journal_issue_tsort desc, journal_page_start_tsort asc, title_sort asc', :label => 'publication year'
    config.add_sort_field 'author_sort asc, title_sort asc', :label => 'first author A-Z'
    config.add_sort_field 'author_sort desc, title_sort asc', :label => 'first author Z-A'
    config.add_sort_field 'title_sort asc, pub_date_tsort desc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
#
    config.add_limit_field 'toc', :helper_method => :toc_limit_display_value, :fields => ['toc_key_s']
    config.add_limit_field 'author', :fields => ['author_ts', 'editor_ts', 'supervisor_ts']
    config.add_limit_field 'subject', :fields => ['keywords_ts']
  end

  def typeahead
  end

  def index
    # Ensure that all responses that renders a search result has /(en|da)/catalog in the url
    # Why: because we want to disallow crawlers from search results but allow crawlers on the index page
    unless request.path.starts_with?(catalog_index_path) || params.except(:controller, :action, :locale).empty?
      redirect_to catalog_index_path(params) and return
    end

    # Require authentication if request has tag parameters
    if any_tag_in_params?
      require_authentication unless can? :tag, Bookmark
    end

    if params[:range] && params[:range][:pub_date_tsort]
      params[:range][:pub_date_tsort] = normalize_year_range(params[:range][:pub_date_tsort])
    end

    #extra_head_content << view_context.auto_discovery_link_tag(:rss, url_for(params.merge(:format => 'rss')), :title => t('blacklight.search.rss_feed') )
    #extra_head_content << view_context.auto_discovery_link_tag(:atom, url_for(params.merge(:format => 'atom')), :title => t('blacklight.search.atom_feed') )

    extra_search_params = {}
    if params[:from_resolver]
      extra_search_params = blacklight_config[:resolver_params]
      params.delete :from_resolver
    end

    @query = URI.encode((params[:q] || ""))
    (@response, @document_list) = get_search_results(params, extra_search_params)
    @filters = params[:f] || []

    respond_to do |format|
      # TODO Blacklight::Catalog calls preferred_view here
      format.html { }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }

      # Add all dynamically added (such as by document extensions)
      # export formats.
      if @document_list.first
        @document_list.first.export_formats.each_key do | format_name |
          # It's important that the argument to send be a symbol;
          # if it's a string, it makes Rails unhappy for unclear reasons.
          format.send(format_name.to_sym) { render :text => export_search_result(format_name, params, extra_search_params), :layout => false }
        end
      end
    end
    monitor_response
  end

  def monitor_response
    return unless Rails.application.config.respond_to?(:monitoring_id)
    return unless @response.present?
    return unless @response.respond_to?(:to_json)
    DtuMonitoring::BlacklightResponse.delay.monitor(Rails.application.config.monitoring_id, @response.to_json, Time.now.to_i)
  end

  def show
    @disable_remove_filter = true
    @show_nal_locations = true

    # override super#show to add access filters to request
    # and to add toc data to response
    begin
      @response, @document = get_solr_response_for_doc_id nil, add_access_filter
      @toc = toc_for @document, params, add_access_filter

    rescue Blacklight::Exceptions::InvalidSolrID

      # check whether document is available for dtu users if the user does not already have dtu search rights
      if can? :search, :public
        @response, @document = get_solr_response_for_doc_id nil, {:fq => ["access_ss:#{Rails.application.config.search[:dtu]}"]}
        if @document.nil?
          not_found
        else
          if current_user.authenticated?
            redirect_to authentication_required_catalog_path(:url => request.url)
          else
            # anonymous user, send to DTU login
            force_authentication({:only_dtu => true})
          end
        end
      else
        not_found
      end
    else
      respond_to do |format|
        format.html {setup_next_and_previous_documents unless params[:ignore_search]}

        # Add all dynamically added (such as by document extensions)
        # export formats.
        @document.export_formats.each_key do | format_name |
          # It's important that the argument to send be a symbol;
          # if it's a string, it makes Rails unhappy for unclear reasons.
          format.send(format_name.to_sym) { render :text => @document.export_as(format_name), :layout => false }
        end
      end
    end
  end

end
