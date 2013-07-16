class PagesController < ApplicationController

  def searchbox
    render("pages/searchbox", :layout => "application")
  end

end
