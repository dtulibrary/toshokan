# -*- encoding : utf-8 -*-
require 'i18n'

class CatalogController < ApplicationController
  layout 'with_search_bar'

  include Dtu::CatalogBehavior
  include Toshokan::Catalog

  before_filter :inject_last_query_into_params, only:[:show]

  configure_blacklight do |config|

    config.solr_path = 'toshokan'
    config.document_solr_path = 'toshokan_document'
    # config.document_presenter_class = Dtu::DocumentPresenter
    config.metrics_presenter_classes = [Dtu::Metrics::AltmetricPresenter, Dtu::Metrics::IsiPresenter, Dtu::Metrics::DtuOrbitPresenter, Dtu::Metrics::PubmedPresenter]

    # Set resolver params
    config.resolver_params = {
      "mm" => "100%"
    }

    # Add support for :limit field type. Used by ToC filters. See also LimitsHelper.
    config[:limit_fields] = {}
    class << config
      def add_limit_field(limit, options={})
        self[:limit_fields][limit] = options
      end
    end

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      :q => '*:*',
      :rows => 10,
      :hl => true,
      'hl.snippets' => 3,
      'hl.usePhraseHighlighter' => true,
      'hl.fl' => 'title_ts, author_ts, journal_title_ts, conf_title_ts, abstract_ts, publisher_ts',
      'hl.fragsize' => 300
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
    # config.per_page = [10, 20, 50]
    config.max_per_page = 500

    # solr field configuration for search results/index views
    config.index.title_field = 'title_ts'
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    config.show.title_field = 'title_ts'
    config.show.display_type_field = 'format'

    ##
    # FACET FIELDS
    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    config.add_facet_field 'format', :collapse => false
    #config.add_facet_field 'subformat_s', :collapse => false
    config.add_facet_field 'pub_date_tsort', :label => I18n.t('blacklight.search.fields.facet.pub_date_tsort'), :range => true
    config.add_facet_field 'author_facet', :limit => 20
    config.add_facet_field 'journal_title_facet', :limit => 20

    ##
    # INDEX FIELDS
    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'author_ts', :helper_method => :render_shortened_author_links, :highlight => true
    config.add_index_field 'journal_title_ts', :format => ['article'], :helper_method => :render_journal_info_index, :highlight => true
    config.add_index_field 'conf_title_ts', :format => ['article'], :helper_method => :render_conference_info_index, :suppressed_by => ['journal_title_ts'], :highlight => true
    config.add_index_field 'pub_date_tis', :format => ['book']
    config.add_index_field 'journal_page_ssf', :format => ['book']
    config.add_index_field 'format', :helper_method => :render_type
    #config.add_index_field 'subformat_s', :helper_method => :render_subtype
    config.add_index_field 'doi_ss'
    config.add_index_field 'publisher_ts', :format => ['book', 'journal'], :highlight => true
    config.add_index_field 'abstract_ts', :helper_method => :render_highlighted_abstract, :highlight => true, separator: ''
    config.add_index_field 'issn_ss', :format => ['journal']
    config.add_index_field 'dissertation_date_ssf', :helper_method => :render_dissertation_date, :format => ['thesis']

    ##
    # SHOW FIELDS
    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'subtitle_ts'
    config.add_show_field 'title_abbr_ts'
    config.add_show_field 'author_ts', :helper_method => :render_author_links
    config.add_show_field 'affiliation_ts', :format => ['book', 'article'], :helper_method => :render_affiliations
    config.add_show_field 'editor_ts', :helper_method => :render_author_links
    config.add_show_field 'pub_date_tis', :format => ['book']
    config.add_show_field 'journal_page_ssf', :format => ['book']
    config.add_show_field 'journal_title_ts', :format => ['article'], :helper_method => :render_journal_info_show
    config.add_show_field 'conf_title_ts', :helper_method => :render_conference_info_show
    config.add_show_field 'format', :helper_method => :render_type
    config.add_show_field 'publisher_ts'
    config.add_show_field 'isbn_ss'
    config.add_show_field 'issn_ss'
    config.add_show_field 'doi_ss'
    config.add_show_field 'language_ss'
    config.add_show_field 'abstract_ts'
    config.add_show_field 'keywords_ts', :helper_method => :render_keyword_links
    config.add_show_field 'udc_ss'
    config.add_show_field 'dissertation_date_ssf', :helper_method => :render_dissertation_date, :format => ['thesis']
    config.add_show_field 'supervisor_ts', :helper_method => :render_author_links

    ##
    # SEARCH FIELDS
    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    config.add_search_field 'all_fields'

    config.add_search_field 'original_config' do |field|
      field.solr_local_parameters = {
          :qf => '$original_qf',
          :pf => '$original_pf'
      }
    end

    config.add_search_field 'title' do |field|
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

    ##
    # SORT FIELDS
    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).

    # sort fields Provided by Dtu::CatalogBehavior - relevance, year, title

    author_ordering = [
        'author_sort asc',
        'title_sort asc'
    ]
    config.add_sort_field author_ordering.join(', '), :label => 'author'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
#
    config.add_limit_field 'toc', :helper_method => :toc_limit_display_value, :fields => ['toc_key_s']
    config.add_limit_field 'author', :fields => ['author_ts', 'editor_ts', 'supervisor_ts']
    config.add_limit_field 'subject', :fields => ['keywords_ts']
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
