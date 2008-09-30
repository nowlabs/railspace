class CommentsController < ApplicationController
  
  before_filter :protect, :load_post
  include ProfileHelper
  
  # Get /posts/new
  def new
    @comment = Comment.new
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def create
    @comment = Comment.new(params[:comment])
    @comment.user = User.find(session[:user_id])
    @comment.post = @post
    
    respond_to do |format|
      if @post.comments << @comment
        format.js
        format.html { redirect_to profile_for(@post.blog.user) }
      else
        format.html { redirect_to new_blog_post_comment_url(@post.blog, @post) }
        format.js { render :nothing => true }
      end
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    user = User.find(session[:user_id])
    
    if @comment.authorized?(user)
      @comment.destroy
    else
      redirect_to hub_url
      return
    end
    
    respond_to do |format|
      format.js
    end
    
  end
  
  private
  
  def load_post
    @post = Post.find(params[:post_id])
  end
  
end
