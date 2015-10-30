module Authenticable

  # Devise methods overwrites
  # why this becomes an object ??? this is a method
  def current_user
    @current_user ||= User.find_by(auth_token: request.headers['Authorization'])
  end

  def authenticate_with_token!
    render json: { errors: "Not authenticated" },
           status: :unauthorized unless user_signed_in?
  end

  def user_signed_in?
    current_user.present?
  end

end