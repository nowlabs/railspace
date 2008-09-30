require File.dirname(__FILE__) + '/../test_helper'

class UserControllerTest < ActionController::TestCase
  
  def setup
    @valid_user = users(:valid_user)
    @invalid_user = users(:invalid_user)
  end
  
  def test_login_page
    get :login
    title = assigns(:title)
    assert_equal "Log in to RailSpace", title
    assert_response :success
    assert_template "login"
    
    action = @controller.url_for(:action => "login", :only_path => true)
    assert_form_block action do
      assert_screen_name_field              
      assert_password_field
      assert_select "input[type=checkbox][name=?]", "user[remember_me]"              
      assert_submit_button("Login!")                        
    end
    
    assert_select "p" do
      assert_select "a[href=?]", @controller.url_for(:action => "register", :only_path => true),
                    :text => "Register now!"
    end
  end
  
  def test_login_success
    try_to_login @valid_user, :remember_me => "0"
    assert @controller.logged_in?
    
    assert_equal @valid_user.id, session[:user_id]
    assert_equal "User #{@valid_user.screen_name} logged in", flash[:notice]
    assert_redirected_to :action => "index"
    
    user = assigns(:user)
    assert user.remember_me != "1"
    assert_nil cookie_value(:remember_me)
    assert_nil cookie_value(:authorization_token)
  end
  
  def test_login_success_with_remember_me
    try_to_login @valid_user, :remember_me => "1"
    test_time = Time.now
    time_range = 100
    assert @controller.logged_in?
    
    assert_equal @valid_user.id, session[:user_id]
    assert_equal "User #{@valid_user.screen_name} logged in", flash[:notice]
    assert_redirected_to :action => "index"
    
    user = User.find(@valid_user.id)
    
    assert_equal "1", cookie_value(:remember_me)
    assert_in_delta 10.years.from_now(test_time), cookie_expires(:remember_me), time_range
    
    assert_equal user.authorization_token, cookie_value(:authorization_token)
    assert_in_delta 10.years.from_now(test_time), cookie_expires(:authorization_token), time_range
  end
  
  def cookie_value(symbol)
    cookies[symbol.to_s].value.first
  end
  
  def cookie_expires(symbol)
    cookies[symbol.to_s].expires
  end
  
  private :cookie_value, :cookie_expires
  
  def try_to_login(user, options = {})
    user_attributes = { :screen_name => user.screen_name, :password => user.password }
    user_attributes.merge!(options)
    post :login, :user => user_attributes
  end
  
  
  private :try_to_login
  
  def test_login_failure_with_nonexistant_screen_name
    invalid_user = @valid_user
    invalid_user.screen_name = "no such user"
    try_to_login invalid_user
    
    assert_template "login"
    assert_response :success
    
    assert_equal "Invalid screen name/password combination", flash[:notice]
    user = assigns(:user)
    assert_equal invalid_user.screen_name, user.screen_name
    assert_nil user.password
  end
  
  def test_login_failure_with_wrong_password
    invalid_user = @valid_user
    invalid_user.password = "baz"
    try_to_login invalid_user
    
    assert_template "login"
    assert_response :success
    
    assert_equal "Invalid screen name/password combination", flash[:notice]
    user = assigns(:user)
    assert_equal invalid_user.screen_name, user.screen_name
    assert_nil user.password
  end
  
  def test_logout
    try_to_login @valid_user, :remember_me => "1"
    assert @controller.logged_in?
    assert_not_nil cookie_value(:authorization_token)
    
    get :logout
    assert_response :redirect
    assert_redirected_to :action => "index", :controller => "site"
    assert_equal "Logged out", flash[:notice]
    assert !@controller.logged_in?
    assert_nil cookie_value(:authorization_token)
  end
  
  def construct_assert_input_field(name, options={})
    options.symbolize_keys!
    raise_option_missing_error(ArgumentError, options, :field_type, :size, :maxlength)
    return "input[name=?][type=?][size=?][maxlength=?]", 
           name, options[:field_type], options[:size], options[:maxlength]
  end
  
  def assert_screen_name_field()
    input_field_params = construct_assert_input_field("user[screen_name]",
                                                      :field_type => "text",
                                                      :size => User::SCREEN_NAME_SIZE,
                                                      :maxlength => User::SCREEN_NAME_MAX_LENGTH)
    assert_select input_field_params
  end
  
  def assert_email_field(options = {})
    options.symbolize_keys!
    input_field_params = construct_assert_input_field("user[email]",
                                                      :field_type => "text",
                                                      :size => User::EMAIL_SIZE,
                                                      :maxlength => User::EMAIL_MAX_LENGTH)
    if options[:value]
      value_field = "[value=?]", options[:value]
      input_field_params.insert(-1, value_field)
    end
    assert_select input_field_params 
  end
  
  def assert_password_field(options = {:password_field_name => "user[password]"})
    options.symbolize_keys!
    input_field_params = construct_assert_input_field(options[:password_field_name],
                                                      :field_type => "password",
                                                      :size => User::PASSWORD_SIZE,
                                                      :maxlength => User::PASSWORD_MAX_LENGTH)
    if options[:value]
      password_field_params = "[value=?]", options[:value]
      input_field_params.insert(-1, password_field_params)
    else
      password_field_params = "[value=?]", options[:value]
      input_field_params.insert(-1, password_field_params)
    end
    
    assert_select input_field_params
  end
    
  private :construct_assert_input_field, :assert_email_field, :assert_password_field,
          :assert_screen_name_field
  
  def test_registration_page
    get :register
    title = assigns(:title)
    assert_equal "Register User", title
    assert_response :success
    assert_template "register"
    
    action = @controller.url_for(:action => "register", :only_path => true)
    assert_form_block action do
      assert_screen_name_field
      assert_email_field                    
      assert_password_field
      assert_password_field :password_field_name => "user[password_confirmation]"
      assert_submit_button("Register!")
    end
  end
  
  def test_edit_page
    authorize @valid_user
    get :edit
    title = assigns(:title)
    assert_equal "Edit User Info", title
    assert_response :success
    assert_template "edit"
    
    url = @controller.url_for(:action => "edit", :only_path => true)
    assert_form_block url do
      assert_email_field :value => @valid_user.email
      assert_password_field :password_field_name => "user[current_password]"
      assert_password_field
      assert_password_field :password_field_name => "user[password_confirmation]"
      assert_submit_button "Update"
    end
  end
  
  def test_valid_registration
    post :register, :user => {:screen_name => "new_screen_name", 
                             :email => "valid@example.net",
                             :password => "1234"}
    user = assigns(:user)
    assert_not_nil user
    
    saved_user = User.find_by_screen_name_and_password(user.screen_name, user.password)
    assert_equal saved_user, user
    
    assert_equal "User #{saved_user.screen_name} created", flash[:notice]
    assert_redirected_to :action => "index"
    
    assert @controller.logged_in?
    assert_equal user.id, session[:user_id]                        
  end
  
  def test_invalid_registration
    post :register, :user => {:screen_name => "an/noyes",
                              :email => "annoyes@example,come",
                              :password => "123"}
    assert_response :success
    assert_template "register"
    
    assert_select "div#?[class=?]", "errorExplanation", "errorExplanation" do
      assert_select "li", :text => /Screen name/
      assert_select "li", :text => /Email/
      assert_select "li", :text => /Password/
      assert_select "li", :count => 3
    end
    
    assert_select "div.fieldWithErrors" do
      assert_select "input[name=?][value=?]", "user[screen_name]", "an/noyes"
      assert_select "input[name=?][value=?]", "user[email]", "annoyes@example,come"
      assert_select "input[name=?]", "user[password]"
    end                        
  end
  
  def test_navigation_when_logged_in
    authorize @valid_user
    get :index
    assert_select "a[href=?]", 
                   @controller.url_for(:action => "logout", :only_path => true),
                   :text => /Logout/
    assert_select "a[href=?]", 
                   @controller.url_for(:action => "index", :only_path => true),
                   :text => /Hub/, :count => 0
                   
    assert_select "a[href~=?]", 
                   @controller.url_for(:action => "register", :only_path => true),
                   :text => "Register", :count => 0
    assert_select "a[href=?]", 
                  @controller.url_for(:action => "login", :only_path => true),
                  :text => /Login/, :count => 0                          
  end
  
  def test_index_unauthorized
    get :index
    assert_response :redirect
    assert_redirected_to :action => "login"
    assert_equal "Please log in first", flash[:notice]
  end
  
  def test_index_authorized
    authorize @valid_user
    get :index
    assert_response :success
    assert_template "index"
  end
  
  
  def test_login_friendly_forwarding
    user = {:screen_name => @valid_user.screen_name,
            :email => @valid_user.email,
            :password => @valid_user.password}
    friendly_url_forwarding_aux(:protected_page => "index", :test_page => "login", :user => user)
  end
  
  def test_register_friendly_forwarding
    user = {:screen_name => "new_screen_name",
            :email => "valid@email.com",
            :password => "long_enough_password"}
    friendly_url_forwarding_aux(:protected_page => "index", :test_page => "register", :user => user)
  end
  
  def friendly_url_forwarding_aux(options = {})
    options.symbolize_keys!
    raise_option_missing_error(ArgumentError, options, :protected_page, :test_page, :user)
    
    get options[:protected_page]
    assert_response :redirect
    assert_redirected_to :action => "login"
    
    post options[:test_page], :user => options[:user]
    assert_response :redirect
    assert_redirected_to :action => options[:protected_page]
    assert_nil session[:protected_page]
  end
    
  private :friendly_url_forwarding_aux
  
end
