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
