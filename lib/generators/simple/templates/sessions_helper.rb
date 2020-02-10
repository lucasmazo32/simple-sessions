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
