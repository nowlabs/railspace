# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  before_filter :check_authorization
  
  helper :all # include all helpers, all the time
  include AuthenticateHelper
  include FunctionHelper
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '7dca466e4859689d61ad4803689f955c'
  
  def check_authorization
    authorization_token = cookies[:authorization_token]
    if authorization_token and not session[:user_id]
      user = User.find_by_authorization_token(authorization_token)
      user.login!(session) if user
    end
  end
  
  def params_posted?(symbol)
    request.post? and params[symbol]
  end
  
  def protect
    unless logged_in?
      session[:protected_page] = request.request_uri
      flash[:notice] = "Please log in first"
      redirect_to :controller => "user", :action => "login"
      return false
    end
  end
  
  def make_profile_vars
    @spec = @user.spec ||= Spec.new
    @faq = @user.faq ||= Faq.new
    @blog = @user.blog || Blog.create(:user => @user)
    @posts = @blog.posts.paginate(:per_page => 3, :page => params[:page])
  end
  
end
