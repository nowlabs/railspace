require File.dirname(__FILE__) + '/../test_helper'

class AvatarControllerTest < ActionController::TestCase
  
  def setup
    @user = users(:valid_user)
  end
  
  def test_upload_and_delete
    authorize @user
    image = uploaded_file("rails.png", "image/png")
    post :upload, :avatar => { :image => image }
    assert_response :redirect
    assert_redirected_to hub_url
    assert_equal "Your avatar has been uploaded", flash[:notice]
    assert @user.avatar.exists?
    post :delete
    assert !@user.avatar.exists?
  end
  
end
