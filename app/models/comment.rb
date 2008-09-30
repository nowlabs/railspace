class Comment < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :post
  
  validates_presence_of :body, :post, :user
  validates_length_of :body, :maximum => DB_TEXT_MAX_LENGTH
  validates_uniqueness_of :body, :scope => [:post_id, :user_id]
  
  def authorized?(user)
    post.blog.user == user
  end
  
end
