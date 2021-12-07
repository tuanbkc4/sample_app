class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      active_user user
    else
      flash.now[:danger] = t("login.fails")
      render :new
    end
  end

  def destroy
    log_out
    redirect_to login_url
  end

  private

  def active_user user
    if user.activated
      log_in user
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_back_or user
    else
      flash[:warning] = t "active_account.not_actived"
      redirect_to root_url
    end
  end
end
