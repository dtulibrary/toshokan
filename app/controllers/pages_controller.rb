class PagesController < ApplicationController

  def searchbox
    render("pages/searchbox", :layout => nil)
  end

end
