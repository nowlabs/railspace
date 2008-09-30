class Post < ActiveRecord::Base
  belongs_to :blog
  has_many :comments, :order => "created_at", :dependent => :destroy
  
  validates_presence_of :title, :body, :blog
  validates_length_of :title, :maximum => DB_STRING_MAX_LENGTH
  validates_length_of :body, :maximum => DB_TEXT_MAX_LENGTH
  
end
