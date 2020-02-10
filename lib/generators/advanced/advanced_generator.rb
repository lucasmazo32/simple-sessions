# frozen_string_literal: true

class AdvancedGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  # Adds the helper, view, controller, test, routes and includes the
  # SessionHelper in the ApplicationController
  def advanced
    copy_file 'sessions_helper.rb', 'app/helpers/sessions_helper.rb'
    copy_file 'new.html.erb', 'app/views/sessions/new.html.erb'
    copy_file 'sessions_controller_test.rb', 'test/controllers/sessions_controller_test.rb'
    copy_file 'sessions_controller.rb', 'app/controllers/sessions_controller.rb'
    copy_file 'custom.scss', 'app/assets/stylesheets/custom.scss'
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
