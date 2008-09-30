require File.dirname(__FILE__) + '/../test_helper'

class SpecControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    @user = users(:valid_user)
    @spec = specs(:valid_spec)
  end
  
  def test_edit_success
    authorize @user
    post :edit,
         :spec => { :first_name => "new first name", :last_name => "new last name",
                    :gender => "Male", :occupation => "new job", :zip_code => "91125" }
    spec = assigns(:spec)
    new_user = User.find(spec.user.id)
    assert_equal new_user.spec, spec
    assert_equal "Changes saved.", flash[:notice]
    assert_response :redirect
    assert_redirected_to :controller => "user", :action => "index"
  end
  
end
