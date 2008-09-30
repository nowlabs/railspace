require File.dirname(__FILE__) + '/../test_helper'

class CommunityControllerTest < ActionController::TestCase
  
  def setup
    User.rebuild_index
    Spec.rebuild_index
    Faq.rebuild_index
  end
  
  def test_search_success
    get :search, :q => "*"
    assert_response :success
    #assert_select "p", :text => /Found 14 matches./
    assert_select "p", :text => /Displaying matches 1&nbsp;-&nbsp;10 of 14 in total/
  end
  
end
