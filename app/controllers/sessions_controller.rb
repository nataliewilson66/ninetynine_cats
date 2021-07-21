class SessionsController < ApplicationController
  before_action :require_no_user!, only: %i(create new)

  def new
    render :new
  end

  def create
    user = User.find_by_credentials(params[:user][:user_name], params[:user][:password])
    unless user.nil?
      login_user!(user)
      redirect_to cats_url
    else
      flash.now[:errors] = ["Incorrect username and/or password"]
      render :new
    end
  end

  def destroy
    logout_user!
    redirect_to new_session_url
  end

  private
  def user_params
    params.require(:user).permit(:user_name, :password)
  end

end