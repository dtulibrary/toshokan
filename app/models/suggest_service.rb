class SuggestService
  def self.query(query, dictionary, solr_instance, suggest_path)
    response = solr_instance.send_and_receive(suggest_path, params: {q: query, 'suggest.dictionary' => dictionary,  wt: :ruby, omitHeader: true})
    response.try(:[], 'suggest').try(:[], dictionary).try(:[], query).try(:[], 'suggestions') || []
  end
end
