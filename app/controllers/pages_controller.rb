class PagesController < ApplicationController
  skip_before_filter :authenticate
  after_action :allow_iframe, :only => [:searchbox, :searchbox_styled]

  def searchbox
    render('pages/searchbox', :layout => nil)
  end

  def searchbox_styled
    render('pages/searchbox_styled', :layout => 'external_page')
  end

  def authentication_required
    if current_user.authenticated?
      redirect_to(params[:url] || root_url) and return
    end
    render :status => :forbidden
  end

  def authentication_required_catalog
    render :status => :forbidden
  end

  def about
    render 'pages/about'
  end
end
