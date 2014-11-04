class AssistanceRequest < ActiveRecord::Base
  belongs_to :user
  has_one :order
  validates :user_id, :presence => true
  attr_protected :type, :user_id
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
      'journal' => [
        {:name => 'journal_title',  :ou => 'jtitle',  :required => true},
        {:name => 'journal_issn',   :ou => 'issn'},
        {:name => 'journal_volume', :ou => 'volume', :required => true},
        {:name => 'journal_issue',  :ou => 'issue',   :required => true, },
        {:name => 'journal_year',   :ou => 'date',    :required => true},
        {:name => 'journal_pages',  :ou => 'pages',   :required => true}
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
        {:name => 'book_edition'},
        {:name => 'book_doi',       :ou => 'doi'},
        {:name => 'book_isbn',      :ou => 'isbn'},
        {:name => 'book_year',      :ou => 'date',   :required => true},
        {:name => 'book_publisher', :ou => 'pub'}
      ]
    }
  end

  def self.fields_for section
    form_sections[section]
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
        if field.has_key?(:ou) && self.has_attribute?(field[:name])
          co.referent.set_metadata(field[:ou], self.read_attribute(field[:name]))
          co.referent.add_identifier("info:doi/#{self.read_attribute(field[:name])}") if field[:ou] == "doi"
          co.referent.add_identifier("urn:issn:#{self.read_attribute(field[:name])}") if field[:ou] == "issn"
        end
      end
    end
    co
  end
end
