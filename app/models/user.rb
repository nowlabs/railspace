require 'digest/sha1'

class User < ActiveRecord::Base
  has_one :spec
  has_one :faq
  has_one :blog
  has_many :friendships
  has_many :friends, :through => :friendships, :conditions => "status = 'accepted'", :order => :screen_name
  has_many :requested_friends, :through => :friendships, :source => :friend, :conditions => "status = 'requested'", :order => :screen_name
  has_many :pending_friends, :through => :friendships, :source => :friend, :conditions => "status = 'pending'", :order => :screen_name
  has_many :comments, :order => "created_at DESC", :dependent => :destroy
  
  
  acts_as_ferret :fields => ['screen_name', 'email']
  
  attr_accessor :remember_me
  attr_accessor :current_password
  
  SCREEN_NAME_MIN_LENGTH = 4
  SCREEN_NAME_MAX_LENGTH = 20
  
  PASSWORD_MIN_LENGTH = 4
  PASSWORD_MAX_LENGTH = 40
  
  EMAIL_MAX_LENGTH = 50
  
  SCREEN_NAME_RANGE = SCREEN_NAME_MIN_LENGTH..SCREEN_NAME_MAX_LENGTH
  PASSWORD_RANGE = PASSWORD_MIN_LENGTH..PASSWORD_MAX_LENGTH
  
  SCREEN_NAME_SIZE = 20
  PASSWORD_SIZE = 10
  EMAIL_SIZE = 30
  
  validates_uniqueness_of :screen_name, :email
  validates_confirmation_of :password
  validates_length_of :screen_name, :within => SCREEN_NAME_RANGE
  validates_length_of :password, :within => PASSWORD_RANGE
  validates_length_of :email, :maximum => EMAIL_MAX_LENGTH
  
  validates_format_of :screen_name,
                      :with => /^[A-Z0-9_]*$/i,
                      :message => "must contain only letters, " + 
                                  "numbers, and underscores"
  
  validates_format_of :email, 
                      :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i,
                      :message => "must be a valid email address"
                      
  def login!(session)
    session[:user_id] = id
  end
  
  def self.logout!(session, cookies)
    session[:user_id] = nil
    cookies.delete(:authorization_token)
  end
  
  def correct_password?(params)
    current_password = params[:user][:current_password]
    password == current_password
  end
  
  def password_errors(params)
    # Equality of New Passwords not checked on incorrect password
    #self.password = params[:user][:password]
    #self.password_confirmation = params[:user][:password_confirmation]
    #valid?
    errors.add(:current_password, "is incorrect")
  end
  
  def remember!(cookies)
    cookie_expiration = 10.years.from_now
    cookies[:remember_me] = { :value => "1", :expires => cookie_expiration }
    self.authorization_token = unique_identifier
    save!
    cookies[:authorization_token] = { :value => authorization_token,
                                      :expires => cookie_expiration }
  end
  
  def forget!(cookies)
    cookies.delete(:remember_me)
    cookies.delete(:authorization_token)
  end
  
  def remember_me?
    remember_me == "1"
  end
  
  def unique_identifier
    Digest::SHA1.hexdigest("#{screen_name}:#{password}")
  end
  
  private :unique_identifier                      
  
  def clear_password!
    self.password = nil
    self.password_confirmation = self.current_password = nil
  end                              
  
  def name
    spec.full_name.or_else(screen_name)
  end
  
  def avatar
    Avatar.new(self)
  end
  
end
