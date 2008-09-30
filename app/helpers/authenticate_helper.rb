module AuthenticateHelper
  
  # Checks if a user is logged in
  def logged_in?
    not session[:user_id].nil?
  end
  
  def logged_out?
    not logged_in?
  end
  
end
