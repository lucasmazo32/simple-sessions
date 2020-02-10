# frozen_string_literal: true

class AdvancedGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  # Adds the helper, view, controller, test, routes and includes the
  # SessionHelper in the ApplicationController
  def create_advanced_file
    copy_file 'new.html.erb', 'app/views/sessions/new.html.erb'
    copy_file 'sessions_controller_test.rb', 'test/controllers/sessions_controller_test.rb'
    create_file 'app/helpers/sessions_helper.rb', <<-FILE
module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def remember(user)
    cookies.permanent.signed[:id] = user.id
    token = SecureRandom.urlsafe_base64
    cookies.permanent[:remember_token] = token
    user.remember(token)
  end

  def create_session(user)
    log_in(user)
    remember(user)
  end

  def current_user
    if session[:user_id]
      @current_user ||= #{file_name.capitalize}.find_by(id: session[:user_id])
    elsif cookies.signed[:id]
      user = #{file_name.capitalize}.find_by(id: cookies.signed[:id])
      cond1 = user.authenticated?(cookies[:remember_token])
      if user && cond1
        @current_user ||= user
        session[:user_id] = user.id
      end
    end
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    @current_user = nil
    session[:user_id] = nil
    cookies.delete :remember_token
    cookies.delete :id
  end

  def correct_user
    redirect_to root_path unless current_user == #{file_name.capitalize}.find(params[:id])
  end

  def login_if_not_logged
    redirect_to login_path unless logged_in?
  end
end
    FILE
    create_file 'app/controllers/sessions_controller.rb', <<-FILE
class SessionsController < ApplicationController
  def new; end

  def create
    user = #{file_name.capitalize}.find_by(username: params[:session][:username].downcase)
    if user&.authenticate(params[:session][:password])
      create_session user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid username/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end
end
    FILE
    copy_file 'custom.scss', 'app/assets/stylesheets/custom.scss'
  end

  def file_changes
    route "get '/login', to: 'sessions#new'"
    route "post '/login', to: 'sessions#create'"
    route "delete '/logout', to: 'sessions#destroy'"
    inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-'RUBY'
  protect_from_forgery with: :exception
  include SessionsHelper
    RUBY
    end
  end

  def inject_user
    inject_into_file "app/models/#{file_name.downcase}.rb", after: "class #{file_name.capitalize} < ApplicationRecord\n" do <<-'RUBY'
  attr_accessor :remember_token
  ############
  # Paste this two functions after your validations and before private (If you have it)
  def remember(token)
    self.remember_token = token
    update_attribute(:remember_digest, BCrypt::Password.create(remember_token))
  end

  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  ############
        RUBY
    end
  end

  def migration
    generate 'migration', "add_remember_digest_to_#{file_name.downcase}s remember_digest:string"
  end
end
