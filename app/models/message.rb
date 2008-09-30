class Message < ActiveRecord::BaseWithoutTable
  
  column :subject, :string
  column :body, :text
  
  validates_presence_of :subject, :body
  validates_length_of :subject, :maximum => DB_STRING_MAX_LENGTH
  validates_length_of :body, :maximum => DB_TEXT_MAX_LENGTH
  
  
end