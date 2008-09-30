require File.dirname(__FILE__) + '/../test_helper'

class PostsControllerTest < ActionController::TestCase
  
  def setup
    @user = users(:valid_user)
    authorize @user
    @post = posts(:one)
    @valid_post = { :title => "New Title", :body => "New Body", :blog => @post.blog }
  end
  
  
  def test_get_index
    get :index, :blog_id => @post.blog
    assert_response :success
    assert assigns(:posts)
  end
  
  
  def test_get_new
    get :new, :blog_id => @post.blog
    assert_response :success
  end
  
  def test_create_post
    assert_difference('Post.count') do
      post :create, :blog_id => @post.blog, :post => @valid_post
    end
    
    assert_redirected_to blog_posts_path(@post.blog)
  end
  
  def test_show_post
    get :show, :blog_id => @post.blog, :id => @post
    assert_response :success
  end
  
  def test_get_edit
    get :edit, :blog_id => @post.blog, :id => @post
    assert_response :success
  end
  
  def test_update_post
    put :update, :blog_id => @post.blog, :id => @post, :post => @valid_post
    assert_redirected_to blog_post_path(@post.blog, assigns(:post))
  end
  
  def test_destroy_post
    assert_difference('Post.count', -1) do
      delete :destroy, :blog_id => @post.blog, :id => @post
    end
  
    assert_redirected_to blog_posts_path(@post.blog)
  end
  
  def test_unauthorized_redirected
    @request.session[:user_id] = nil
    [:index, :new, :show, :edit].each do |responder|
      get responder
      assert_response :redirect
      assert_redirected_to :controller => "user", :action => "login"
    end
  end
  
  def test_catch_blog_id_mismatch
    authorize users(:friend)
    put :update, :blog_id => @post.blog, :id => @post, :post => @valid_post
    assert_response :redirect
    assert_redirected_to hub_url
    assert_equal "That isn't your blog.", flash[:notice]
  end
  
end
