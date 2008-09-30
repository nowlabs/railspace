require File.dirname(__FILE__) + '/../test_helper'


class RememberMeTest < ActionController::IntegrationTest
  
  def setup
    @user = users(:valid_user)
  end
  
  def test_remember_me    
    post "user/login", :user => { :screen_name => @user.screen_name,
                                  :password => @user.password,
                                  :remember_me => "1" }
    assert_equal "user", @controller.controller_name
    @request.session[:user_id] = nil
    assert @controller.logged_out?
        
    get "site/index"
    assert @controller.logged_in?
    assert_equal "site", @controller.controller_name
    assert_equal @user.id, @request.session[:user_id]
  end
  
end
