require File.dirname(__FILE__) + '/../test_helper'

class CommentsControllerTest < ActionController::TestCase
  
  def setup
    @user = users(:valid_user)
    authorize @user
    @comment = comments(:one)
    @post = posts(:one)
    @valid_comment = { :user_id => @user, :post_id => @post, :body => "Comments Body" }
  end
  
  def test_get_new
    xhr :get, :new, :blog_id => @post.blog, :post_id => @post
    assert_response :success
  end
  
  def test_create_comment
    assert_difference('Comment.count') do
      xhr :post, :create, :blog_id => @post.blog, :post_id => @post, :comment => @valid_comment
    end
    assert_response :success
  end
  
  def test_destroy_comment
    assert_difference('Comment.count', -1) do
      xhr :delete, :destroy, :blog_id => @post.blog, :post_id => @post, :id => @comment
    end
    assert_response :success
  end
  
  def test_unauthorized_delete_comment
    authorize users(:friend)
    xhr :delete, :destroy, :blog_id => @post.blog, :post_id => @post, :id => @comment
    assert_response :redirect
    assert_redirected_to hub_url
  end
  
end
