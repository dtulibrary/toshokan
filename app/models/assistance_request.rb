class AssistanceRequest < ActiveRecord::Base
  belongs_to :user
  has_one :order
 
  validates :user_id, :presence => true

  serialize :physical_location, JSON

  def self.auto_cancel_values_in_days
    ['180', '90' ,'30']
  end

  def self.form_sections
    {
      'article' => [
        {:name => 'article_title',  :ou => 'atitle', :required => true},
        {:name => 'article_author', :ou => 'au'},
        {:name => 'article_doi',    :ou => 'doi'}
      ],
      'thesis' => [
        {:name => 'thesis_title',       :ou => 'btitle', :required => true},
        {:name => 'thesis_author',      :ou => 'au',     :required => true},
        {:name => 'thesis_affiliation'},
        {:name => 'thesis_publisher',   :ou => 'pub'},
        {:name => 'thesis_type'},
        {:name => 'thesis_year',        :ou => 'date',   :required => true},
        {:name => 'thesis_pages',       :ou => 'pages'}
      ],
      'report' => [
        {:name => 'report_title',     :ou => 'btitle', :required => true},
        {:name => 'report_author',    :ou => 'au'},
        {:name => 'report_publisher', :ou => 'pub'},
        {:name => 'report_doi',       :ou => 'doi'},
        {:name => 'report_number'}
      ],
      'standard' => [
        {:name => 'standard_title',    :ou => 'atitle', :required => true},
        {:name => 'standard_subtitle'},
        {:name => 'standard_publisher'},
        {:name => 'standard_doi',      :ou => 'doi'},
        {:name => 'standard_number'},
        {:name => 'standard_isbn',     :ou => 'isbn'},
        {:name => 'standard_year',     :ou => 'date',   :required => true},
        {:name => 'standard_pages',    :ou => 'pages'}
      ],
      'patent' => [
        {:name => 'patent_title',      :ou => 'atitle', :required => true},
        {:name => 'patent_inventor'},
        {:name => 'patent_number'},
        {:name => 'patent_year',       :ou => 'date', :required => true},
        {:name => 'patent_country'}
      ],
      'other' => [
        {:name => 'other_title',       :ou => 'atitle', :required => true},
        {:name => 'other_author',      :ou => 'au'},
        {:name => 'other_publisher'},
        {:name => 'other_doi',         :ou => 'doi'}
      ],
      'journal' => [
        {:name => 'journal_title',  :ou => 'jtitle',  :required => true},
        {:name => 'journal_issn',   :ou => 'issn'},
        {:name => 'journal_volume', :ou => 'volume',  :required => true},
        {:name => 'journal_issue',  :ou => 'issue'},
        {:name => 'journal_year',   :ou => 'date',    :required => true},
        {:name => 'journal_pages',  :ou => 'pages',   :required => true}
      ],
      'host' => [
        {:name => 'host_title',     :ou => 'jtitle'},
        {:name => 'host_isxn',      :ou => -> isxn { isxn.issn? ? 'issn' : 'isbn' }},
        {:name => 'host_volume',    :ou => 'volume'},
        {:name => 'host_issue',     :ou => 'issue'},
        {:name => 'host_year',      :ou => 'date',    :required => true},
        {:name => 'host_pages',     :ou => 'pages'},
        {:name => 'host_series',    :ou => 'series'}
      ],
      'notes' => [
        {:name => 'notes'}
      ],
      'conference' => [
        {:name => 'conference_title', :ou => 'jtitle', :required => true},
        {:name => 'conference_location'},
        {:name => 'conference_year',  :ou => 'date', :required => true},
        {:name => 'conference_isxn' },
        {:name => 'conference_pages', :ou => 'pages', :required => true}
      ],
      'book' => [
        {:name => 'book_title',     :ou => 'btitle', :required => true},
        {:name => 'book_author',    :ou => 'au'},
        {:name => 'book_edition',   :ou => 'edition'},
        {:name => 'book_doi',       :ou => 'doi'},
        {:name => 'book_isbn',      :ou => 'isbn'},
        {:name => 'book_year',      :ou => 'date',   :required => true},
        {:name => 'book_publisher', :ou => 'pub'}
      ],
      'automatic cancellation' => [
        {:name => 'auto_cancel'}
      ],
      'physical delivery' => [
        {:name => 'physical_delivery'}
      ]
    }
  end

  def self.fields_for section
    form_sections[section]
  end

  def self.relevant_form_sections
    ['article', 'journal', 'host', 'thesis', 'report', 'standard', 'patent',
     'other', 'notes', 'conference', 'book', 'automatic cancellation', 'physical delivery']
  end

  def self.fields
    if @fields.nil?
      @fields = []
      relevant_form_sections.each do |section|
        @fields += fields_for(section).map {|field_info| field_info[:name].to_sym}
      end
    end
    return @fields
  end

  def self.required_fields_for section
    form_sections[section].select {|e| e[:required]}.collect {|e| e[:name]}
  end

  def self.optional_fields_for section
    form_sections[section].reject {|e| e[:required]}.collect {|e| e[:name]}
  end

  def generate_openurl(sections, format, genre)
    co = OpenURL::ContextObject.new
    co.referent.set_format(format)
    co.referent.set_metadata('genre', genre)

    sections.each do |section|
      self.class.fields_for(section).each do |field|
        if field.has_key?(:ou) && !self.send(field[:name]).blank?
          field_value = self.send(field[:name])
          rft_key     = field[:ou].is_a?(Proc) ? field[:ou].(field_value) : field[:ou]
          co.referent.set_metadata(rft_key, field_value)
          co.referent.add_identifier("info:doi/#{field_value}") if rft_key == "doi"
          co.referent.add_identifier("urn:issn:#{field_value}") if rft_key == "issn"
          co.referent.add_identifier("urn:isbn:#{field_value}") if rft_key == "isbn"
        end
      end
    end
    co
  end
end
