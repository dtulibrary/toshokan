# -*- coding: utf-8 -*-
module MendeleyHelper

  def refresh_access_token

  end

  def mendeley_folders_and_groups
    folders = JSON.parse(HTTParty.get('https://api.mendeley.com/folders', { :headers => { 'Authorization' => "Bearer #{session[:mendeley_access_token].token}" } }).body)
    groups  = JSON.parse(HTTParty.get('https://api.mendeley.com/groups', { :headers => { 'Authorization' => "Bearer #{session[:mendeley_access_token].token}" } }).body)

    groups.each do |g|
      g['folders'] = [] # JSON.parse(HTTParty.get("https://api.mendeley.com/folders?group_id=#{g['id']}", { :headers => { 'Authorization' => "Bearer #{session[:mendeley_access_token].token}" } }).body)
      # TODO Haven't yet figured out how to add a document to a group folder. So lets not present group folders to the user.
    end

    logger.info folders.inspect
    logger.info fold_mendeley_folders(folders).inspect
    logger.info groups.inspect

    return folders, groups
  end

  def fold_mendeley_folders(folders, parent = nil, level = 0)
    folders.select{|f| f['parent_id'] == parent }.map do |f|
      [ f.tap{ |f| f['level'] = level }, fold_mendeley_folders(folders, f['id'], level + 1) ]
    end
  end

  def render_mendeley_folders(folders, parent = nil, initial_level = 0)
    fold_mendeley_folders(folders, parent, initial_level).flatten.compact.map{ |f| content_tag('option', '   ' * f['level'] + f['name'], :value => "#{f['id']}") }.join(' ').html_safe
  end

  def render_mendeley_groups(groups)
    groups.map{ |g| content_tag('option', g['name'], :value => "@#{g['id']}") + render_mendeley_folders(g['folders'], nil, 1) }.join(' ').html_safe
  end

  def save_to_mendeley(solr_documents, folder, tags, options = {})
    p = Progress.create({:name => options[:progress_name], :start => 0, :end => solr_documents.count, :current => 0, :stop => false, :finished => false}) if options[:progress_name]
    Thread.new do
      solr_documents.each_with_index do |d,i|
        next if d['format'] == 'journal'
        save_document_to_mendeley d, folder, tags
        if options[:progress_name]
          p.current = i+1
          p.save
        end
      end
      if options[:progress_name]
        p.finished = true
        p.save
      end
      ActiveRecord::Base.connection.close
    end
  end

  def save_document_to_mendeley(solr_document, folder, tags)
    folder, group = folder.split('@')
      mendeley_document = solr_to_mendeley(solr_document, group, tags).to_json

      logger.info mendeley_document

      response = HTTParty.post('https://api.mendeley.com/documents', {
          :headers       => {
            'Authorization' => "Bearer #{session[:mendeley_access_token].token}",
            'Accept'        => 'application/vnd.mendeley-document.1+json',
            'Content-Type'  => 'application/vnd.mendeley-document.1+json',
          },
          :body          => mendeley_document
        })

      logger.info response.inspect

      unless folder.blank?
        saved_document = response.body
        response = HTTParty.post("https://api.mendeley.com/folders/#{folder}/documents", {
            :headers       => {
              'Authorization' => "Bearer #{session[:mendeley_access_token].token}",
              'Accept'        => 'application/vnd.mendeley-document.1+json',
              'Content-Type'  => 'application/vnd.mendeley-document.1+json',
            },
            :body          => saved_document
          })
        logger.info response.inspect
      end
  end

  def solr_to_mendeley(solr_document, group, tags)
    {
      :type        => mendeley_type(solr_document[:format]),
      :title       => solr_document[:title_ts].try(:first),
      :year        => solr_document[:pub_date_tis].try(:first),
      :source      => solr_document[:journal_title_ts].try(:first) || solr_document[:conf_title_ts].try(:first),
      :abstract    => solr_document[:abstract_ts].try(:first),
      :authors     => solr_document[:author_ts].map{|a| Hash[[:last_name, :first_name].zip(a.split(',').map(&:strip))]},
      :pages       => solr_document[:journal_page_ssf].try(:first),
      :volume      => solr_document[:journal_vol_ssf].try(:first),
      :issue       => solr_document[:journal_issue_ssf].try(:first),
      :publisher   => solr_document[:publisher_ssf].try(:first),
      :keywords    => solr_document[:keywords_ts],
      :institution => ('Technical University of Denmark' if solr_document[:format] == 'thesis'),
      :identifiers => mendeley_identifiers(solr_document),
      :websites    => [catalog_url(:id => solr_document[:cluster_id_ss].first)],
      :tags        => tags,
      :confirmed   => true,
      :group_id    => group,
    }.delete_if{ |k, v| v.blank? }

  end

  def mendeley_type(format)
    {
      'article' => 'journal',
      'book'    => 'book',
      'thesis'  => 'thesis',
    }[format]
  end

  def mendeley_identifiers(solr_document)
    identifiers = {}
    identifiers[:doi]    = solr_document[:doi_ss].try(:first)
    identifiers[:issn]   = solr_document[:issn_ss].try(:first)
    identifiers[:isbn]   = solr_document[:isbn_ss].try(:first)
    identifiers[:scopus] = get_source_id(solr_document, :scopus)
    identifiers[:pmid]   = get_source_id(solr_document, :pubmed)
    identifiers[:arxiv]  = get_source_id(solr_document, :arxiv)
    identifiers.delete_if{ |k, v| v.blank? }
  end

  def get_source_id(solr_document, source)
    solr_document[:source_id_ss].find{|id| id.start_with?(source.to_s)}.try(:split, ':').try(:last)
  end
end
