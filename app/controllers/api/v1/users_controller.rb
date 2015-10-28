class Api::V1::UsersController < ApplicationController
  before_action :authenticate_with_token!, only: [:update, :destroy]

  respond_to :json
  def show
    respond_with User.find(params[:id])
  end

  def create
    user = User.new(user_params)
    puts "user token " +user.email
    puts "user email " + user.password
    if user.save
      render json: user, status: 201, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def update
    if @current_user.update(user_params)
      render json: @current_user, status: 200, location: [:api, @current_user]
    else
      render json: { errors: @current_user.errors }, status: 422
    end
  end

  def destroy
    @current_user.destroy
    head 204
  end

  private
    def user_params
      params.require(:user).permit(:email, :password,:password_confirmation)
    end
end
