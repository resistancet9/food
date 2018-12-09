require "sinatra"
require "sinatra/activerecord"
require "sinatra/flash"
require "./models"

enable :sessions

configure :development do
  set :database, "sqlite3:app.db"
end

configure :production do
  # this environment variable is auto generated/set by heroku
  #   check Settings > Reveal Config Vars on your heroku app admin panel
  set :database, ENV["DATABASE_URL"]
end


get "/" do
  if session[:user_id]
    @posts = Post.all
    @user = User.find(session[:user_id])
    erb :signed_in_homepage
  else
    erb :signed_out_homepage
  end
end

post "/" do
  @user = User.find(session[:user_id])
  @post = Post.create(
    user_id: @user.id,
    title: params[:title],
    content: params[:content]
  )
  redirect "/"
end

# displays sign in form
get "/sign-in" do
  erb :sign_in
end

# responds to sign in form
post "/sign-in" do
  @user = User.find_by(username: params[:username])

  # checks to see if the user exists
  #   and also if the user password matches the password in the db
  if @user && @user.password == params[:password]
    # this line signs a user in
    session[:user_id] = @user.id

    # lets the user know that something is wrong
    # flash[:info] = "You have been signed in"

    # redirects to the home page
    redirect "/"
  else
    # lets the user know that something is wrong
    flash[:warning] = "Your username or password is incorrect"

    # if user does not exist or password does not match then
    #   redirect the user to the sign in page
    redirect "/sign-in"
  end
end

# displays signup form
#   with fields for relevant user information like:
#   username, password
get "/sign-up" do
  erb :sign_up
end

post "/sign-up" do
  @user = User.create(
    first_name: params[:first_name],
    last_name: params[:last_name],
    username: params[:username],
    password: params[:password],
    email: params[:email],
    image_url: params[:image_url],
    birthday: params[:birthday]
  )

  # this line does the signing in
  session[:user_id] = @user.id

  # lets the user know they have signed up
  # flash[:info] = "Thank you for signing up"

  # assuming this page exists
  redirect "/"
end

get "/create-post" do
  if session[:user_id]
  erb :create_post
  else
  redirect "/"
  end
end

post '/create-post' do
  @user = User.find(session[:user_id])
  @post = Post.create(
    user_id: @user.id,
    title: params[:title],
    content: params[:content]
  )
  redirect "/"
end

get "/profile" do

  if session[:user_id]
    @user = User.find(session[:user_id])
  erb :profile
  else
  redirect "/"
  end
end

post "/profile" do
  @user = User.find(session[:user_id])
  @post = Post.create(
    user_id: @user.id,
    title: params[:title],
    content: params[:content]
  )
  redirect "/profile"
end


get "/user-profile/:id" do
  @user = User.find(params[:id])
  @posts = User.find(params[:id]).posts
  erb :other_users_posts
end 


get "/settings" do
  if session[:user_id]
    @user = User.find(session[:user_id])
    erb :settings 
  else
  redirect "/"
  end
end 

post "/settings" do
    @user = User.find(session[:user_id])

  if @user.username == params[:username] && @user.password == params[:password]
    @user.posts.each do |post|
       Post.destroy(post.id)
    end
    User.destroy(session[:user_id])
    session[:user_id] = nil
    flash[:warning] = "You have deleted your account"
    redirect "/"

  else 
    flash[:warning] = "Your username or password is incorrect"
    redirect "/settings"

  end
end

put "/settings" do 
  @user = User.find(session[:user_id])
  @user.update(
    first_name: params[:first_name], 
    last_name: params[:last_name], 
    username: params[:username], 
    password: params[:password], 
    email: params[:email], 
    image_url: params[:image_url])
    
    flash[:info] = "You have updated your account"
    redirect "/settings"
end

# when hitting this get path via a link
#   it would reset the session user_id and redirect
#   back to the homepage
get "/sign-out" do
  # this is the line that signs a user out
  session[:user_id] = nil

  # lets the user know they have signed out
  flash[:info] = "You have been signed out"
  
  redirect "/"
end


get "/delete-post/:id" do
  @post = Post.find(params[:id])
  Post.destroy(@post.id)
  redirect "/"
end

