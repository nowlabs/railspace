class PostsController < ApplicationController
  
  before_filter :protect, :protect_blog
  before_filter :protect_post, :only => [:show, :edit, :update, :destroy]
  
  # GET /posts
  # GET /posts.xml
  def index
    @posts = @blog.posts.paginate(:per_page => 3, :page => params[:page])
    @title = "Blog Management"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])
    @title = @post.title

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new(:blog => @blog)
    @title = "Add a new post"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
    @title = "Edit #{@post.title}"
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to blog_posts_path(@blog) }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to blog_post_path(@blog, @post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to blog_posts_url(@blog) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def protect_blog
    @blog = Blog.find(params[:blog_id])
    user = User.find(session[:user_id])
    unless @blog.user == user
      flash[:notice] = "That isn't your blog."
      redirect_to hub_url
      return false
    end
  end
  
  def protect_post
    post = Post.find(params[:id])
    unless post.blog == @blog
      flash[:notice] = "That isn't your blog!"
      redirect_to hub_url
      return false
    end
  end
  
end

