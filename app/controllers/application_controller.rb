class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  # fix default render errors
  include ActionController::ImplicitRender
  include Authenticable
end
