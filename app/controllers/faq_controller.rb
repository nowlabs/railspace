class FaqController < ApplicationController
  
  before_filter :protect
  
  def index
    redirect_to hub_url
  end

  def edit
    @title = "Edit FAQ"
    @user = User.find(session[:user_id])
    @faq = @user.faq ||= Faq.new
    if params_posted?(:faq)
      if @user.faq.update_attributes(params[:faq])
        flash[:notice] = "FAQ saved"
        redirect_to hub_url
      end
    end
  end

end