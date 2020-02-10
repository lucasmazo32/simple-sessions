# Simple sessions

To use the gem type `gem 'simple_sessions', '~> 0.2.0'` in your Gemfile.

The objective of this gem is to make your life easier when creating sessions. Creating sessions (especially the ones with permanent secure cookies) can be difficult or can take up some time for the programmer; therefore, I hope this will make your life easier.

# Version 0.2.0

After running `bundle update` and `bundle` you should be able to run:

> `rails g simple NAME` *or* `rails g advanced NAME`

I strongly recommend NOT to run the programm if you already have a session controller. This will generate conflicts with the files that are going to be created.

## How does it work?

It will automatically generate the view, controller, helper, test (for this version there are no automatic tests!), routes in your config/routes.rb and add the SessionsHelper to your ApplicationController.

For this program, 'NAME' means the name of the database. Taking into consideration that the database should be singular (like User), you should write the name in singular. It doesn't matter if you write it in capital letters or downcase, the program will automatically recognize it. What it doesn't understand is the plural version of the word.

*e.g:*

> `rails g advanced user` *correct*

> `rails g advanced users` *wrong!*

You can always run `rails destroy advanced NAME` or `rails destroy simple NAME`, but remember that if you had a mistake writing the name, you probably are going to get an error (although most of the times you can ignore them).

I strongly recommend creating the user's database before running this command, because it will generate a migration to add the column **remember_digest** to your user's schema.

## Which one to pick
Simple sessions are an easy way of making your sessions. Those only include a cookie with an encrypted user_id which will expire after the browser is closed. This is an easy way of testing your apps in your localhost without expending time in creating the functions necessary for creating sessions.

Advanced sessions also include cookies that expire in 20 years (Thus, permanent). They cover more functions and is more secure (User's id is saved encrypted in a cookie, and for the remember_digest, I use BCrypt hash security and a urlsafe_base64 for generating the tokens that will go in the remember column.

## Files generated and recommendations

- `custom.scss`: This file imports the bootstrap configuration, which will be used to automatically style de buttons and form fields.
- `new.html.erb`: View containing the form for logging in users. 
- `sessions_controller_test.rb`: File in which you can generate your tests for the session.
- `sessions_controller.rb`: File in which the logic of finding the right user lives. This file doesn't change too much between *simple* and *advanced*.
- `sessions_helper.rb`: All the logic involving the sessions live here. The cookies and session information lives in here.
- `migration file (ONLY FOR ADVANCED)`: It will create a migration to add the column **remember_digest** to the database for your users.

### new.html.erb
```
<%= form_for(:session, url: login_path) do |f| %>
            
  <%= f.label :username %>
  <%= f.text_field :username, class: 'form-control' %>

  <%= f.label :password %>
  <%= f.password_field :password, class: 'form-control' %>

  <%= f.submit 'Sign up!', class: 'btn btn-primary' %>
<% end %>
```

### sessions_controller.rb
```
class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(username: params[:session][:username].downcase)
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
```

### sessions_helper.rb (simple)
```
module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    @current_user = nil
    session[:user_id] = nil
  end

  def correct_user
    redirect_to root_path unless current_user == User.find(params[:id])
  end

  def login_if_not_logged
    redirect_to login_path unless logged_in?
  end
end
```

### sessions_helper.rb (advanced)
```
module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def remember(user)
    cookies.permanent.signed[:user_id] = user.id
    token = SecureRandom.urlsafe_base64
    cookies.permanent[:remember_token] = token
    user.remember_digest = Digest::SHA2.hexdigest token
  end

  def create_session(user)
    log_in(user)
    remember(user)
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:id]
      user = User.find_by(id: cookies.signed[:id])
      cond1 = Digest::SHA2.hexdigest(cookies[:remember_token]) ==
              user.remember_digest
      if user & cond1
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
    redirect_to root_path unless current_user == User.find(params[:id])
  end

  def login_if_not_logged
    redirect_to login_path unless logged_in?
  end
end
```

### time_add_remember_digest_to_NAME.rb
```
class AddRememberDigestToName < ActiveRecord::Migration[X.0]
  def change
    add_column :names, :remember_digest, :string
  end
end
```

# Recommendations
Use rails 5.0.0 or newer versions.

# Conclusion

Note that the only thing that changes between the controllers is the use of create_session instead of a simple log_in, otherwise is the same thing. The way of how the session's functions are organized allows you to spend less time worrying about the code you write, but in how your application will work. I hope you enjoy it!

# Author
Lucas Mazo: [Github](https://github.com/lucasmazo32)

# Built with:
- Ruby ~> 2.6.5
- VSCode