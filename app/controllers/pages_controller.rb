class PagesController < ApplicationController

  def searchbox
    render("pages/searchbox", :layout => nil)
  end
  
  def searchbox_styled
    render("pages/searchbox_styled", :layout => "external_page")
  end

end
