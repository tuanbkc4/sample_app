class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new show create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)

  def new
    @user = User.new
  end

  def show; end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "active_account.send_confirm"
      redirect_to root_url
    else
      render :new
    end
  end

  def index
    @pagy, @users = pagy(User.all, items: Settings.length.items)
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t "users.update.success"
      redirect_to @user
    else
      render "edit"
    end
  end

  def destroy
    if user&.destroy
      flash[:success] = t "users.destroy.success"
    else
      flash[:danger] = t "users.destroy.danger"
    end
    redirect_to users_url
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "users.not_found"
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :birthday,
      :gender
    )
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "users.login.danger"
    redirect_to login_url
  end

  def correct_user
    @user = User.find_by(id: params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
