class SiteController < ApplicationController

  def index
    @title = "RailSpace"
  end

  def about
    @title = "About RailSpace"
  end

  def help
    @title = "RailSpace Help"
  end
end
