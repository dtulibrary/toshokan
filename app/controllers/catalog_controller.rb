# -*- encoding : utf-8 -*-
require 'blacklight/catalog'
require 'i18n'

class CatalogController < ApplicationController

  include Blacklight::Catalog

  include TagsHelper

  self.solr_search_params_logic += [:add_tag_fq_to_solr]
  self.solr_search_params_logic += [:add_access_filter]

  configure_blacklight do |config|
    # It seems the I18n path is not set by Rails prior to running this block.
    # (other stuff like the Rails logger has not been initialized here either)
    # TODO: Would really be nice not to have this kind of thing. Possible fixes:
    #   - Go back to configuring BL in an initializer
    #   - Push translation lookup into BL and hope that pull request would get accepted
    Dir[Rails.root + 'config/locales/*.yml'].each { |path| I18n.load_path << path }

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


    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      :qt => '/ds',
      :q => '*:*',
      :rows => 10
    }

    ## Default parameters to send on single-document requests to Solr. These
    ## settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.default_document_solr_params = {
      :qt => '/ds_document'
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    }

    # solr field configuration for search results/index views
    config.index.show_link = 'title_t'
    config.index.record_display_type = 'format'

    # solr field configuration for document/show views
    config.show.html_title = 'title_t'
    config.show.heading = 'title_t'
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
    config.add_labeled_field :facet, 'pub_date_sort', :range => true
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
    # config.add_labeled_field :index, 'title_t'
    config.add_labeled_field :index, 'author_t', :helper_method => :render_shortened_author_links
    config.add_labeled_field :index, 'journal_title_s', :helper_method => :render_journal_info_index
    config.add_labeled_field :index, 'pub_date_ti'
    config.add_labeled_field :index, 'doi_s', :helper_method => :render_doi_link
    config.add_labeled_field :index, 'abstract_t', :helper_method => :snip_abstract

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_labeled_field :show, 'title_t'
    config.add_labeled_field :show, 'author_t', :helper_method => :render_author_links
    config.add_labeled_field :show, 'affiliation_t', :helper_method => :render_affiliations
    config.add_labeled_field :show, 'journal_title_s', :helper_method => :render_journal_info_show
    config.add_labeled_field :show, 'isbn_s'
    config.add_labeled_field :show, 'issn_s'
    config.add_labeled_field :show, 'doi_s', :helper_method => :render_doi_link
    config.add_labeled_field :show, 'format'
    config.add_labeled_field :show, 'keywords_t', :helper_method => :render_keyword_links
    config.add_labeled_field :show, 'abstract_t'

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
    config.add_labeled_field :search, 'subject' do |field|
      #field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      #field.qt = 'search'
      field.solr_local_parameters = {
        :qf => '$subject_qf',
        #:pf => '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_labeled_field :sort, 'score desc, pub_date_sort desc, title_sort asc', :field_name => 'relevance'
    config.add_labeled_field :sort, 'pub_date_sort desc, title_sort asc', :field_name => 'year'
    config.add_labeled_field :sort, 'author_sort asc, title_sort asc', :field_name => 'author'
    config.add_labeled_field :sort, 'title_sort asc, pub_date_sort desc', :field_name => 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  def add_access_filter solr_parameters, user_parameters
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << 'access:dtu' if can? :search, :dtu
    solr_parameters[:fq] << 'access:dtupub' if can? :search, :public
  end

  def current_display_format
    display_format = params[:display] || 'standard'

    # Revert to standard format if user can't view requested format
    display_format = 'standard' unless can? :view_format, display_format
    display_format
  end

  def index
    @display_format = current_display_format + '_index'
    logger.debug 'Empty q'
    orig_q = params[:q];
    # Check for advanced search parameters
    nested_queries = []
    nested_queries << orig_q if orig_q && !orig_q.blank?
    blacklight_config.search_fields.collect { |f| f unless (f[0] == 'all_fields') || (f[1].solr_local_parameters[:qf].nil?) }.compact.each do |field_name, field|
      if params[field_name] && !params[field_name].empty?
        logger.debug "Adding field #{field_name}"
        nested_queries << "_query_:{!edismax qf=#{field.solr_local_parameters[:qf]}}#{params[field_name]}"
      end
    end
    unless nested_queries.empty?
      match_mode = params[:match_mode] || 'all'
      joiner = (match_mode == 'all') ? ' AND ' : ' OR '
      params[:q] = nested_queries.join(joiner)
    end
    super
    params[:q] = orig_q
  end

  def show
    @display_format = current_display_format + '_show'
    super
  end

end
