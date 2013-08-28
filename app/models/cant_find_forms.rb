class CantFindForms

  def self.genre_matrix
    { 
      :journal_article => {
        :tips => [
          'refine_search', 
          'google_scholar',
        ],
        :forms => [
          'article', 
          'journal', 
          'notes', 
          [
            'email', 
            { :dtu_staff => 'physical_location', :dtu_student => 'pickup_location' },
            'submit',
          ]
        ],
      },
      :conference_article => {
        :tips => [
          'refine_search',
        ],
        :forms => [
          [
            'article',
            'proceedings',
          ],
          'conference',
          'notes',
          [
            'email',
            { :dtu_staff => 'physical_location', :dtu_student => 'pickup_location' },
            'submit',
          ],
        ],
      },
      :book => {
        :tips => [
          'refine_search',
          'bibliotek_dk',
          'google_books',
        ],
        :forms => [
          'book',
          'publisher',
          'notes',
          [
            'email',
            { :dtu_staff => 'physical_location', :dtu_student => 'pickup_location' },
            'submit',
          ],
        ],
      },
    }
  end

  def self.form_fields_matrix
    {
      :article => [
        { :name => 'article_title', :mandatory => true },
        { :name => 'author' },
        { :name => 'doi' },
      ],
      :journal => [
        { :name => 'journal_title', :mandatory => true },
        { :name => 'issn' },
        { :name => 'volume', :mandatory => true },
        { :name => 'issue', :mandatory => true },
        { :name => 'year', :mandatory => true },
        { :name => 'pages', :mandatory => true },
      ],
      :notes => [
        { :name => 'notes' }, 
      ],
      :conference => [
        { :name => 'conference_title', :mandatory => true },
        { :name => 'number' },
        { :name => 'year', :mandatory => true },
        { :name => 'location' },
      ],
      :proceedings => [
        { :name => 'proceedings_title' },
        { :name => 'proceedings_isxn' },
        { :name => 'pages', :mandatory => true },
      ],
      :book => [
        { :name => 'book_title', :mandatory => true },
        { :name => 'author' },
        { :name => 'edition' },
        { :name => 'doi' },
        { :name => 'isbn' },
        { :name => 'year' },
      ],
      :publisher => [
        { :name => 'publisher_name' },
      ],
    }
  end

  def self.form_fields_for section
    form_fields_matrix[section.to_sym]
  end

  def self.form_fields_values section, fields, params
    result = { section => {} }
    fields.each do |field|
      result[section][field] = params[field] unless params[field].blank?
    end 
    result
  end 

  # Returns a hash of form sections for a given genre with field names and corresponding values.
  # Only fields that have actual (non-blank) content is returned.
  #
  # Example:
  #
  # CantFindForms.submitted_values_for :journal_article
  # =>
  # { 
  #   'article' => {
  #     'article_title' => 'Some title',
  #     'author' => 'Mr. Smith',
  #     'doi' => '10.1234/12345678'
  #   },
  #   'journal' => {
  #     'journal_title' => 'Fancy journal title',
  #     'issn' => '12345678',
  #     'volume' => '1',
  #     'issue' => '3',
  #     'year' => '1999',
  #     'pages' => '12-23'
  #   },
  #   'notes' => {
  #     'notes' => 'My impressive notes'
  #   }
  # }
  def self.submitted_values_for genre, params
    result = {}
    case genre
    when :journal_article
      result.deep_merge! form_fields_values('article', ['article_title', 'author', 'doi'], params)
      result.deep_merge! form_fields_values('journal', ['journal_title', 'issn', 'volume', 'issue', 'year', 'pages'], params)
    when :conference_article
      result.deep_merge! form_fields_values('article', ['article_title', 'author', 'doi'], params)
      result.deep_merge! form_fields_values('proceedings', ['proceedings_title', 'proceedings_isxn', 'pages'], params)
      result.deep_merge! form_fields_values('conference', ['conference_title', 'number', 'year', 'location'], params)
    when :book
      result.deep_merge! form_fields_values('book', ['book_title', 'author', 'edition', 'doi', 'isbn', 'year'], params)
      result.deep_merge! form_fields_values('publisher', ['publisher_name'], params)
    end 
    result.deep_merge! form_fields_values('notes', ['notes'], params)
  end

  def self.tips_for genre
    genre_matrix[genre][:tips]
  end

  def self.form_sections_for genre
    genre_matrix[genre][:forms]
  end

end
