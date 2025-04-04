class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ new create ]
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :ensure_current_user, only: %i[ edit update destroy ]

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit; end

  # POST /users
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        sign_in(@user)
        redirect_to @user, notice: t(".success")
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

# PATCH/PUT /users/1
def update
  respond_to do |format|
    if user_params[:password].present?
      if @user.update_with_password(user_params)
        redirect_to @user, notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    else
      if @user.update(user_params.except(:password, :password_confirmation))
        redirect_to @user, notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end
end

  # DELETE /users/1
  def destroy
    @user.destroy!

    respond_to do |format|
      redirect_to user_session_path, status: :see_other, notice: t(".success")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :age, :height, :weight, :gender)
    end

    def ensure_current_user
      user = User.find(params[:id])
      unless user.id == current_user.id
        redirect_to user_path(current_user)
      end
    end
end
