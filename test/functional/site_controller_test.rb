require File.dirname(__FILE__) + '/../test_helper'

class SiteControllerTest < ActionController::TestCase
  
  def test_index
    get :index
    title = assigns(:title)
    assert_equal "RailSpace", title
    assert_response :success
    assert_template "index"
  end
  
  def test_about
    get :about
    title = assigns(:title)
    assert_equal "About RailSpace", title
    assert_response :success
    assert_template "about"
  end
  
  def test_help
    get :help
    title = assigns(:title)
    assert_equal "RailSpace Help", title
    assert_response :success
    assert_template "help"
  end
  
  def test_navigation_when_not_logged_in
    get :index
    assert_select "a[href~=?]", 
                   @controller.url_for(:action => "register", :controller => "user", :only_path => true),
                   :text => "Register"
    assert_select "a[href=?]", 
                  @controller.url_for(:action => "login", :controller => "user", :only_path => true),
                  :text => /Login/
    assert_select "a[href=?]", @controller.url_for(:action => "index", :only_path => true),
                  :text => "Home", :count => 0
  end
  
  
end
