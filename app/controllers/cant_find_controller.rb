class CantFindController < ApplicationController

  before_filter :disable_header_searchbar

  def index
    @genre = genre
    if [:journal_article, :conference_article, :book].include? @genre
      @tips = CantFindForms.tips_for @genre
      @form_sections = CantFindForms.form_sections_for @genre
      render 'index'
    else
      render :text => "Genre '#{@genre}' not supported.", :status => :bad_request
    end
  end

  def genre
    (params[:genre] || :journal_article).to_sym
  end

  def assistance
    @sections = CantFindForms.submitted_values_for genre, params
    @form_sections = CantFindForms.form_sections_for(genre)
    SendIt.delay.send_request_assistance_mail genre, current_user, params
  end

end
