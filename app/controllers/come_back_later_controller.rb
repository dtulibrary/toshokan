class ComeBackLaterController < CatalogController
  skip_before_filter :check_walk_in_only

  def index
    session[:come_back_later] = true
  end
end
