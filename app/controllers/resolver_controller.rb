class ResolverController < ActionController::Base

  def index
    new_params = {}
    genre = value_map['genre'][params['genre']]

    modded_params = {}
    params.each do |k,v|
      modded_params[k.downcase] = v
    end

    param_map[genre].each do |k,v|
      new_params[v] = modded_params[k] unless modded_params[k].blank?
    end

    flash[:notice] = %q{DTU Findit was unable to resolve your request to a document. 
                        You have been redirected to the request assistance form.'}

    redirect_to new_assistance_request_path(:genre => genre, :assistance_request => new_params)
  end

  # Map from parameter names sent from Scholar to parameter names used in
  # assistance requests
  def param_map
    {
      :journal_article => {
        'article'  => 'article_title',
        'journal' => 'journal_title',
        'issn'    => 'journal_issn',
        'volume'  => 'journal_volume',
        'issue'   => 'journal_issue',
        'year'    => 'journal_year',
        'pages'   => 'journal_pages'
      }
    }
  end

  def value_map
    {
      'genre' => {
        'article' => :journal_article
      }
    }
  end

end
