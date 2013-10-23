class AssistanceRequest < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  attr_protected :type, :user_id
  serialize :physical_location, JSON

  def self.form_sections
    {
      'article' => [
        {:name => 'article_title', :required => true},
        {:name => 'article_author'},
        {:name => 'article_doi'}
      ],  
      'journal' => [
        {:name => 'journal_title',  :required => true},
        {:name => 'journal_issn'},
        {:name => 'journal_volume', :required => true},
        {:name => 'journal_issue',  :required => true},
        {:name => 'journal_year',   :required => true},
        {:name => 'journal_pages',  :required => true}
      ],  
      'notes' => [
        {:name => 'notes'}
      ],  
      'proceedings' => [
        {:name => 'proceedings_title'},
        {:name => 'proceedings_isxn'},
        {:name => 'proceedings_pages', :required => true}
      ],  
      'conference' => [
        {:name => 'conference_title', :required => true},
        {:name => 'conference_location'},
        {:name => 'conference_year', :required => true},
        {:name => 'conference_number'}
      ],  
      'book' => [
        {:name => 'book_title', :required => true},
        {:name => 'book_author'},
        {:name => 'book_edition'},
        {:name => 'book_doi'},
        {:name => 'book_isbn'},
        {:name => 'book_year', :required => true}
      ],  
      'publisher' => [
        {:name => 'publisher_name'}
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
end
