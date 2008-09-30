require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < ActionMailer::TestCase
  tests UserMailer
  
  def setup
    @user = users(:valid_user)
    @friend = users(:friend)
  end
  
  def test_reminder
    reminder = UserMailer.create_reminder(@user)
    assert_equal 'test1@nowlabs.net', reminder.from.first
    assert_equal 'Your login information at railspace.local', reminder.subject
    assert_equal @user.email, reminder.to.first
    assert_match /Screen name: #{@user.screen_name}/, reminder.body
    assert_match /Password: #{@user.password}/, reminder.body
  end
  
  def test_message
    user_url = "http://railspace.local/profile/#{@user.screen_name}"
    reply_url = "http://railspace.local/email/correspond/#{@user.screen_name}"
    message = Message.new(:subject => "Test Message", :body => "This is totally cool!")
    email = UserMailer.create_message(:user => @user, :recipient => @friend, :message => message, :user_url => user_url, :reply_url => reply_url)
    assert_equal message.subject, email.subject
    assert_equal @friend.email, email.to.first
    assert_equal 'test1@nowlabs.net', email.from.first
    assert_match message.body, email.body
    assert_match user_url, email.body
    assert_match reply_url, email.body
  end
  
end
