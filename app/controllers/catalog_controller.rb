# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController  

  include Blacklight::Catalog

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = { 
      :q => '*:*',
      :rows => 10 
    }
    
    config.solr_request_handler = 'ds_group'

    ## Default parameters to send on single-document requests to Solr. These 
    ## settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or 
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}' 
    #}

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
    config.add_facet_field 'format', :label => 'Format' 
    config.add_facet_field 'pub_date', :label => 'Publication Year', :range => true 
    config.add_facet_field 'author_name_facet', :label => 'Authors', :limit => 20
    config.add_facet_field 'journal_title_facet', :label => 'Journals', :limit => 20  

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.default_solr_params[:'facet.field'] = config.facet_fields.keys
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys


    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display 
    config.add_index_field 'title_t', :label => 'Title:' 
    #config.add_index_field 'title_vern_display', :label => 'Title:' 
    config.add_index_field 'author_name_t', :label => 'Author:' 
    #config.add_index_field 'author_vern_display', :label => 'Author:' 
    config.add_index_field 'format', :label => 'Format:' 
    config.add_index_field 'language_t', :label => 'Language:'
    config.add_index_field 'journal_title_t', :label => 'Journal title:'
    #config.add_index_field 'published_display', :label => 'Published:'
    #config.add_index_field 'published_vern_display', :label => 'Published:'
    #config.add_index_field 'lc_callnum_display', :label => 'Call number:'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display 
    config.add_show_field 'title_t', :label => 'Title:' 
    #config.add_show_field 'title_vern_display', :label => 'Title:' 
    #config.add_show_field 'subtitle_display', :label => 'Subtitle:' 
    #config.add_show_field 'subtitle_vern_display', :label => 'Subtitle:' 
    config.add_show_field 'author_t', :label => 'Author:' 
    #config.add_show_field 'author_vern_display', :label => 'Author:' 
    config.add_show_field 'format', :label => 'Format:' 
    #config.add_show_field 'url_fulltext_display', :label => 'URL:'
    #config.add_show_field 'url_suppl_display', :label => 'More Information:'
    config.add_show_field 'language_t', :label => 'Language:'
    #config.add_show_field 'published_display', :label => 'Published:'
    #config.add_show_field 'published_vern_display', :label => 'Published:'
    #config.add_show_field 'lc_callnum_display', :label => 'Call number:'
    config.add_show_field 'isbn_t', :label => 'ISBN:'
    config.add_show_field 'journal_title_t', :label => 'Journal Title:'

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
    
    config.add_search_field 'all_fields', :label => 'All Fields'
    

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields. 
    
    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params. 
      field.solr_parameters = { :'spellcheck.dictionary' => 'title' }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = { 
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end
    
    config.add_search_field('author') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
      field.solr_local_parameters = { 
        :qf => '$author_qf',
        :pf => '$author_pf'
      }
    end
    
    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as 
    # config[:default_solr_parameters][:qt], so isn't actually neccesary. 
    config.add_search_field('subject') do |field|
      field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
      field.qt = 'search'
      field.solr_local_parameters = { 
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', :label => 'relevance'
    config.add_sort_field 'pub_date_sort desc, title_sort asc', :label => 'year'
    config.add_sort_field 'author_sort asc, title_sort asc', :label => 'author'
    config.add_sort_field 'title_sort asc, pub_date_sort desc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  # a solr query method
  # given a user query, return a solr response containing both result docs and facets
  # - mixes in the Blacklight::Solr::SpellingSuggestions module
  #   - the response will have a spelling_suggestions method
  # Returns a two-element array (aka duple) with first the solr response object,
  # and second an array of SolrDocuments representing the response.docs
  def get_search_results(user_params = params || {}, extra_controller_params = {})

    # In later versions of Rails, the #benchmark method can do timing
    # better for us. 
    bench_start = Time.now

    solr_response = find_with_groups(self.solr_search_params(user_params).merge(extra_controller_params))  
    document_list = solr_response["grouped"].last["groups"].collect {|doc| SolrGroup.new(doc, solr_response)}  
    Rails.logger.debug("Solr fetch: #{self.class}#get_search_results (#{'%.1f' % ((Time.now.to_f - bench_start.to_f)*1000)}ms)")
    
    return [solr_response, document_list]
  end
  
  def get_solr_response_for_doc_id
    id = params["id"].gsub("group-", "") 
    solr_response = find_with_groups({:q => "cluster_id:#{id}"})  
    document = SolrGroup.new(solr_response["grouped"].last["groups"].first, solr_response) 
    return [solr_response, document]
  end    
  
  def find_with_groups(search_params)
    logger.info(search_params)
    solr = RSolr.connect Blacklight.solr_config
    solr_response = solr.get "ds_group", :params => search_params    
    GroupedSolrResponse.new(solr_response, "", search_params)
  end  
  
  def get_single_doc_via_search(index, request_params)
    solr_params = solr_search_params(request_params)

    solr_params[:start] = (index - 1) # start at 0 to get 1st doc, 1 to get 2nd.    
    solr_params[:rows] = 1
    solr_params[:fl] = '*'
    solr_response = find_with_groups(solr_params)
    SolrGroup.new(solr_response["grouped"].last["groups"].first, solr_response) unless solr_response.docs.empty?
  end

end 
