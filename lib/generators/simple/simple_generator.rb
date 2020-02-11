# frozen_string_literal: true

class SimpleGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  # Adds the helper, view, controller, test, routes and includes the
  # SessionHelper in the ApplicationController
  def simple
    copy_file 'new.html.erb', 'app/views/sessions/new.html.erb'
    copy_file 'sessions_controller_test.rb', 'test/controllers/sessions_controller_test.rb'
    copy_file 'custom.scss', 'app/assets/stylesheets/custom.scss'
    create_file 'app/helpers/sessions_helper.rb', <<-FILE
module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= #{file_name.capitalize}.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    @current_user = nil
    session[:user_id] = nil
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
      log_in user
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
    route "get '/login', to: 'sessions#new'"
    route "post '/login', to: 'sessions#create'"
    route "delete '/logout', to: 'sessions#destroy'"
    inject_into_file 'app/controllers/application_controller.rb', after: "class ApplicationController < ActionController::Base\n" do <<-'RUBY'
  protect_from_forgery with: :exception
  include SessionsHelper
    RUBY
    end
  end
end
