class SuggestService
  def self.query(query, solr_instance, suggest_path)
    response = solr_instance.send_and_receive(suggest_path, params: {q: query, wt: :ruby, omitHeader: true})
    response.try(:[], 'suggest').try(:[], 'metastore_dictionary_lookup').try(:[], query).try(:[], 'suggestions') || []
  end
end
