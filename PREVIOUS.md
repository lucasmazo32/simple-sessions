# How to use it

To use them, you should create the session controller writing the following command in your terminal:

> $ rails g controller Sessions new

Specify the correct routes and then go to the session helper and copy these two lines:

> `require 'simple_sessions'`

> `include Simple` *or* `include Advanced`

- Only include one: either Simple or Advanced. Continue reading to find out the difference.

## Which one to pick
Simple sessions are an easy way of making your sessions. Those only include a cookie with an encrypted user_id which will expire after the browser is closed. This is an easy way of testing your apps in your localhost without expending time in creating the functions necessary for creating sessions.

Advanced sessions also include cookies that expire in 20 years (Thus, permanent). They cover more functions and is more secure (User's id is saved encrypted in a cookie, and for the remember_digest, I use SHA2 hash security and a urlsafe_base64 for generating the tokens that will go in the remember column. 

## include Simple

Functions:

> `log_in(user)`: As the name says, it logs in the user.
current_user: It tells you the name of the current user or nil if there is no current user.

> `logged_in?`: It tells you if there is a signed user or not.
>`log_out`: logs the user out.

Instance variables:

> `@current_user`: This can be used if needed in your views. It has the hash containing all the user's information.

## include Advanced
Functions:

>`create_session(user)`: We used log_in for logging in the user in the simple session, but since this one creates a remember_digest and cookies with other information.

>`current_user`: It tells you the name of the current user or nil if there is no current user.

>`logged_in?`: It tells you if there is a signed user or not.

>`log_out`: logs the user out.

Instance variables:

> `@current_user`: This can be used if needed in your views. It has the hash containing all the user's information.

# Session controller

## Example for simple Session Controller
```
  def new; end

  def create
    user = User.find_by(username: params[:session][:username].downcase)
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
```
## Example for Advanced Session controller
```
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