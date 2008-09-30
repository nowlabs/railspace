require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @valid_user = users(:valid_user)
    @invalid_user = users(:invalid_user)
    @error_messages = ActiveRecord::Errors.default_error_messages
  end
  
  # this user should be valid by construction
  def test_user_validity
    assert @valid_user.valid?
  end
  
  # this user should be invalid by construction
  def test_user_invalidity
    assert !@invalid_user.valid?
    attributes = [:screen_name, :email, :password]
    attributes.each do |attr|
      assert @invalid_user.errors.invalid?(attr)
    end
  end
  
  
  def test_uniqueness_of_screen_name_and_email
    user_repeat = User.new(:screen_name => @valid_user.screen_name,
                           :email => @valid_user.email,
                           :password => @valid_user.password)
    assert !user_repeat.valid?
    assert_equal @error_messages[:taken], user_repeat.errors.on(:screen_name)
    assert_equal @error_messages[:taken], user_repeat.errors.on(:email)
  end
  
  def test_screen_name_length_boundaries
    assert_length :min, @valid_user, :screen_name, User::SCREEN_NAME_MIN_LENGTH
    assert_length :max, @valid_user, :screen_name, User::SCREEN_NAME_MAX_LENGTH
  end
  
  def test_password_length_boundaries
    assert_length :min, @valid_user, :password, User::PASSWORD_MIN_LENGTH
    assert_length :max, @valid_user, :password, User::PASSWORD_MAX_LENGTH
  end
  
  def test_screen_name_minimum_length
    user = @valid_user
    min_length = User::SCREEN_NAME_MIN_LENGTH
    
    user.screen_name = "a" * (min_length - 1)
    assert !user.valid?, "#{user.screen_name} should raise a minimum length error"
    
    correct_error_message = sprintf(@error_messages[:too_short], min_length)
    assert_equal correct_error_message, user.errors.on(:screen_name)
    
    user.screen_name = "a" * min_length
    assert user.valid?, "#{user.screen_name} should be just long enough to pass"
  end
  
  def test_screen_name_maximum_length
    user = @valid_user
    max_length = User::SCREEN_NAME_MAX_LENGTH
    
    user.screen_name = "a" * (max_length + 1)
    assert !user.valid?, "#{user.screen_name} should raise a maximum length error"
    
    correct_error_message = sprintf(@error_messages[:too_long], max_length)
    assert_equal correct_error_message, user.errors.on(:screen_name)
    
    user.screen_name = "a" * max_length
    assert user.valid?, "#{user.screen_name} should be just short enough to pass"
  end
  
  def test_password_maximum_length
    user = @valid_user
    max_length = User::PASSWORD_MAX_LENGTH
    
    user.password = "a" * (max_length + 1)
    assert !user.valid?, "#{user.password} should raise a maximum length error"
    
    correct_error_message = sprintf(@error_messages[:too_long], max_length)
    assert_equal correct_error_message, user.errors.on(:password)
    
    user.password = "a" * max_length
    assert user.valid?, "#{user.password} should be just short enough to pass"
  end
  
  def test_email_maximum_length
    user = @valid_user
    max_length = User::EMAIL_MAX_LENGTH
    
    user.email = "a" * (max_length - user.email.length + 1) + user.email
    assert !user.valid?, "#{user.password} should raise a maximum length error"
    
    correct_error_message = sprintf(@error_messages[:too_long], max_length)
    assert_equal correct_error_message, user.errors.on(:email)    
  end
  
  def test_email_with_valid_examples
    user = @valid_user
    valid_tlds = %w{com org net edy es jp au info ca}
    valid_emails = valid_tlds.collect do |tld|
      "foo.bar_1-9@baz-quux0.example.#{tld}"
    end
    
    valid_emails.each do |test_email|
      user.email = test_email
      assert user.valid?, "#{test_email} must be a valid email address"      
    end
  end
  
  def test_email_with_invalid_examples
    user = @valid_user
    invalid_emails = %w{ foobar@example.c @example.com f@com foo@bar..com
                        foobar@example.infod foobar.example.com foo,@example.com
                        foo@ex(ample.com foo@example,com }
    invalid_emails.each do |test_email|
      user.email = test_email
      assert !user.valid?, "#{test_email} test as valid but shouldn't be"
      assert_equal "must be a valid email address", user.errors.on(:email)
    end                                        
  end
  
  def test_screen_name_with_valid_examples
    user = @valid_user
    valid_screen_names = %w{aure michael web_20}
    valid_screen_names.each do |test_screen_name|
      user.screen_name = test_screen_name
      assert user.valid?, "#{test_screen_name} should pass validation but doesn't"
    end
  end
  
  def test_screen_name_with_invalid_examples
    user = @valid_user
    invalid_screen_names = %w{rails/rocks web2.0 javascript:something}
    invalid_screen_names.each do |test_screen_name|
      user.screen_name = test_screen_name
      assert !user.valid?, "#{test_screen_name} shouldn't pass validation but does"
    end
  end
  
end
