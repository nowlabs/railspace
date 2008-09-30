class UserMailer < ActionMailer::Base
  
  def reminder(user)
    @subject = 'Your login information at railspace.local'
    @body = {}
    @body["user"] = user
    @recipients = user.email
    @from = "Test One <test1@nowlabs.net>"
  end
  
  def message(mail)
    subject mail[:message].subject
    from 'Test One <test1@nowlabs.net>'
    recipients mail[:recipient].email
    body mail
  end
  
  def friend_request(mail)
    subject 'New friend request at railspace.local'
    from 'Test One <test1@nowlabs.net>'
    recipients mail[:friend].email
    body mail
  end

end
