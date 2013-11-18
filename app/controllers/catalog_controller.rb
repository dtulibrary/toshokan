# -*- encoding : utf-8 -*-
require 'blacklight/catalog'
require 'i18n'

class CatalogController < ApplicationController

  include Blacklight::Catalog

  include CatalogHelper

  include TagsHelper
  include LimitsHelper
  include AdvancedSearchHelper
  include TocHelper

  before_filter :detect_search_mode

  self.solr_search_params_logic += [:add_tag_fq_to_solr]
  self.solr_search_params_logic += [:add_limit_fq_to_solr]
  self.solr_search_params_logic += [:add_access_filter]

  configure_blacklight do |config|
    # It seems the I18n path is not set by Rails prior to running this block.
    # (other stuff like the Rails logger has not been initialized here either)
    # TODO: Would really be nice not to have this kind of thing. Possible fixes:
    #   - Go back to configuring BL in an initializer
    #   - Push translation lookup into BL and hope that pull request would get accepted
    Dir[Rails.root + 'config/locales/**/*.{rb,yml}'].each { |path| I18n.load_path << path }

    class << config
      # Wrapper on top of blacklight's config.add_*_field that simplifies I18n support for toshokan
      # - field_type is the type of field (:index, :show, :search, :facet, :sort)
      # - field_name is the name of the field which is used for i18n lookup
      #   (using a key like "toshokan.catalog.<field_type>_field_labels.<args[:field_name] || field_name>")
      # - args is options passed on to the config.add_*_field method - except for args[:field_name]
      #   which is used to override the i18n lookup otherwise based on the field_name argument.
      #   If args[:label] is present then no i18n will be performed.
      # - any block given is passed on to the config.add_*_field method
      def add_labeled_field(field_type, field_name, args = {}, &block)
        effective_field_name = args[:field_name] || field_name
        args[:label] ||= I18n.translate("toshokan.catalog.#{field_type.to_s}_field_labels.#{effective_field_name}")
        args.delete :field_name
        send "add_#{field_type.to_s}_field".to_sym, field_name.to_s, args, &block
      end
    end

    # Add support for :limit field type. Used by ToC filters. See also LimitsHelper.
    config[:limit_fields] = {}
    class << config
      def add_limit_field(limit, options={})
        self[:limit_fields][limit] = options
      end
    end


    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      :qt => '/toshokan',
      :q => '*:*',
      :rows => 10
    }

    ## Default parameters to send on single-document requests to Solr. These
    ## settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
      :qt => '/toshokan_document',
      :q => "{!raw f=#{SolrDocument.unique_key} v=$id}"
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    }

    # solr field configuration for search results/index views
    config.index.show_link = 'title_ts'
    config.index.record_display_type = 'format'

    # solr field configuration for document/show views
    config.show.html_title = 'title_ts'
    config.show.heading = 'title_ts'
    config.show.display_type = 'format'

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
    config.add_labeled_field :facet, 'format', :always_expand => true
    config.add_labeled_field :facet, 'pub_date_tsort', :range => true
    config.add_labeled_field :facet, 'author_facet', :limit => 20
    config.add_labeled_field :facet, 'journal_title_facet', :limit => 20

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_labeled_field :index, 'author_ts', :helper_method => :render_shortened_author_links
    config.add_labeled_field :index, 'journal_title_ts', :format => ['article'], :helper_method => :render_journal_info_index
    config.add_labeled_field :index, 'pub_date_tis', :format => ['book']
    config.add_labeled_field :index, 'journal_page_ssf', :format => ['book']
    config.add_labeled_field :index, 'format', :helper_method => :render_type
    config.add_labeled_field :index, 'doi_ss'
    config.add_labeled_field :index, 'publisher_ts', :format => ['book', 'journal']
    config.add_labeled_field :index, 'abstract_ts', :helper_method => :snip_abstract
    config.add_labeled_field :index, 'issn_ss', :format => ['journal']
    config.add_labeled_field :index, 'dissertation_date_ssf', :helper_method => :render_dissertation_date

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_labeled_field :show, 'title_ts'
    config.add_labeled_field :show, 'subtitle_ts'
    config.add_labeled_field :show, 'title_abbr_ts'
    config.add_labeled_field :show, 'author_ts', :helper_method => :render_author_links
    config.add_labeled_field :show, 'affiliation_ts', :format => ['book', 'article'], :helper_method => :render_affiliations
    config.add_labeled_field :show, 'editor_ts', :helper_method => :render_author_links
    config.add_labeled_field :show, 'pub_date_tis', :format => ['book']
    config.add_labeled_field :show, 'journal_page_ssf', :format => ['book']
    config.add_labeled_field :show, 'journal_title_ts', :format => ['article'], :helper_method => :render_journal_info_show
    config.add_labeled_field :show, 'conf_title_ts'
    config.add_labeled_field :show, 'format', :helper_method => :render_type
    config.add_labeled_field :show, 'publisher_ts'
    config.add_labeled_field :show, 'isbn_ss'
    config.add_labeled_field :show, 'issn_ss'
    config.add_labeled_field :show, 'doi_ss'
    config.add_labeled_field :show, 'language_ss'
    config.add_labeled_field :show, 'abstract_ts'
    config.add_labeled_field :show, 'keywords_ts', :helper_method => :render_keyword_links
    config.add_labeled_field :show, 'udc_ss'
    config.add_labeled_field :show, 'dissertation_date_ssf', :helper_method => :render_dissertation_date
    config.add_labeled_field :show, 'supervisor_ts', :helper_method => :render_author_links

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
    config.add_labeled_field :search, 'all_fields'

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    config.add_labeled_field :search, 'title' do |field|
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

    config.add_labeled_field :search, 'author' do |field|
      #field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = {
        :qf => '$author_qf',
        #:pf => '$author_pf'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    #config.add_labeled_field :search, 'subject' do |field|
    #  field.solr_local_parameters = {
    #    :qf => '$subject_qf',
    #  }
    #end

    config.add_labeled_field :search, 'numbers' do |field|
      field.include_in_simple_select = false
      field.solr_local_parameters = {
        :qf => '$numbers_qf'
      }
    end

    config.add_labeled_field :search, 'journal_title' do |field|
      field.include_in_simple_select = false
      field.solr_local_parameters = {
        :qf => '$journal_title_qf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_labeled_field :sort, 'score desc, pub_date_tsort desc, journal_vol_sort asc, journal_issue_sort desc, journal_page_start_tsort asc, title_sort asc', :field_name => 'relevance'
    config.add_labeled_field :sort, 'pub_date_tsort desc, journal_vol_sort asc, journal_issue_sort desc, journal_page_start_tsort asc, title_sort asc', :field_name => 'year'
    config.add_labeled_field :sort, 'author_sort asc, title_sort asc', :field_name => 'author'
    config.add_labeled_field :sort, 'title_sort asc, pub_date_tsort desc', :field_name => 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    config.add_labeled_field :limit, 'toc', :helper_method => :toc_limit_display_value, :fields => ['toc_key_s']
    config.add_labeled_field :limit, 'author', :fields => ['author_ts', 'editor_ts', 'supervisor_ts']
    config.add_labeled_field :limit, 'subject', :fields => ['keywords_ts']

  end

  def current_display_format
    display_format = params[:display] || 'standard'

    # Revert to standard format if user can't view requested format
    display_format = 'standard' unless can? :view_format, display_format
    display_format
  end

  def advanced
    session[:advanced_search] = true
    index
  end

  def detect_search_mode
    session[:advanced_search] ||= params[:advanced_search]
    session.delete :advanced_search if params[:simple_search] || request.fullpath == '/'
  end

  def index
    # Ensure that all responses that renders a search result has /(en|da)/catalog in the url
    # Why: because we want to disallow crawlers from search results but allow crawlers on the index page
    unless (request.path == catalog_index_path) || params.except(:controller, :action, :locale).empty?
      redirect_to catalog_index_path(params)
    end

    @display_format = current_display_format + '_index'
    orig_q = params[:q];

    params.merge! advanced_query_params if advanced_search?

    if params[:range] && params[:range][:pub_date_tsort]
      params[:range][:pub_date_tsort] = normalize_year_range(params[:range][:pub_date_tsort])
    end

    super

    # Restore params
    params[:q] = orig_q

    # If user is in advanced search mode then show the advanced search form
    render 'advanced' if !has_search_parameters? && advanced_search?
  end

  def show
    @disable_remove_filter = true
    @display_format = current_display_format + '_show'
    
    @show_nal_locations = true

    # TODO: Fix problem with nested queries getting dropped from search
    #       when using the next and previous links on show page
    params.merge! advanced_query_params if advanced_search?

    # override super#show to add access filters to request
    # and to add toc data to response
    begin
      @response, @document = get_solr_response_for_doc_id nil, add_access_filter
      @toc = toc_for @document, params, add_access_filter

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
    rescue Blacklight::Exceptions::InvalidSolrID
      not_found
    end
  end

  def journal
    id = journal_id_for_issns(params[:issn]) or not_found
    redirect_to catalog_path :id => id, :key => params[:key], :ignore_search => params[:ignore_search]
  end

  # Definition of solr local parameter references that are not
  # defined in the solr search handler used for searching.
  # NOTE: These should NOT be prefixed by '$' here.
  # TODO: As these go into solr config they should be removed from here
  def solr_referenced_parameters
    { 
      'numbers_qf' => 'issn_ss isbn_ss doi_ss',
      'journal_title_qf' => 'journal_title_ts'
    }
  end

  def solr_search_params local_params = params || {}
    result = super
    user_queries = {}
    advanced_search_fields.each do |field_name, field|
      if local_params[field_name] && !local_params[field_name].blank?
        user_queries[field_name] = local_params[field_name]
      end
    end
    result.merge(user_queries).merge solr_referenced_parameters
  end

  def setup_document_by_counter counter
    return if counter < 1

    if has_advanced_search_parameters? session[:search]
      get_single_doc_via_search counter, session[:search].merge(advanced_query_params session[:search])
    else
      super
    end
  end

  # Saves the current search (if it does not already exist) as a models/search object
  # then adds the id of the search object to session[:history] (if not logged in) or
  # add the search to the users searches
  def save_current_search_params    
    # If it's got anything other than controller, action, total, we
    # consider it an actual search to be saved. Can't predict exactly
    # what the keys for a search will be, due to possible extra plugins.
    return if (search_session.keys - [:controller, :action, :total, :counter, :commit, :locale]) == [] 
    params_copy = search_session.clone # don't think we need a deep copy for this
    params_copy.delete(:page)        
    params_copy.delete(:s_id)        

    # don't save default 'empty' search
    unless params[:q].blank? && params[:f].blank? && params[:l].blank? && params[:t].blank?

      index = @search_history.collect { |search| search.query_params }.index(params_copy)
      if index.nil?


        new_search = Search.create(:query_params => params_copy)
        search_id = new_search.id

        if can? :view, :search_history
          current_user.searches << new_search
          current_user.save      
        else  
          session[:history].unshift(new_search.id)
          # Only keep most recent X searches in history, for performance. 
          # both database (fetching em all), and cookies (session is in cookie)
          session[:history] = session[:history].slice(0, Blacklight::Catalog::SearchHistoryWindow)
        end
      else
        search_id = @search_history[index].id
      end

      params[:s_id] = search_id
    end
  end
end
