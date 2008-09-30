require File.dirname(__FILE__) + '/../test_helper'

class FriendshipControllerTest < ActionController::TestCase
  
  include ProfileHelper
  
  def setup
    @user = users(:valid_user)
    @friend = users(:friend)
    ActionMailer::Base.delivery_method = :test
  end
  
  def test_create
    authorize @user
    get :create, :id => @friend.screen_name
    assert_response :redirect
    assert_redirected_to profile_for(@friend)
    assert_equal "Friend request sent.", flash[:notice]
    
    authorize @friend
    get :accept, :id => @user.screen_name
    assert_redirected_to hub_url
    assert_equal "Friendship with #{@user.screen_name} accepted.", flash[:notice]
  end
  
end
