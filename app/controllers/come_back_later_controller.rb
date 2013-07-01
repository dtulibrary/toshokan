class ComeBackLaterController < CatalogController
  skip_before_filter :check_walk_in_only

  def index
    unless Rails.application.config.walk_in[:only]
      session.delete :come_back_later
      redirect_to root_path
    end
    session[:come_back_later] = true
  end
end
