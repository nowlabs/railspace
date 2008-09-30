require File.dirname(__FILE__) + '/../test_helper'

class EmailControllerTest < ActionController::TestCase
  include ProfileHelper
  
  def setup
    @user = users(:valid_user)
    @friend = users(:friend)
    @emails = ActionMailer::Base.deliveries
    @emails.clear
    ActionMailer::Base.delivery_method = :test
  end
  
  def test_password_reminder
    post :remind, :user => { :email => @user.email }
    assert_response :redirect
    assert_redirected_to :action => "index", :controller => "site"
    assert_equal "Login information was sent.", flash[:notice]
    assert_equal 1, @emails.length
  end
  
  def test_correspond
    authorize @user
    post :correspond, :id => @friend.screen_name, :message => {:subject => "Test message", :body => "This is totally cool!"}
    assert_response :redirect
    assert_redirected_to profile_for(@friend)
    assert_equal "Email sent.", flash[:notice]
    assert_equal 1, @emails.length
  end
end
