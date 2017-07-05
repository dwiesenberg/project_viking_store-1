class Admin::UsersController < AdminController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(safe_user_params)
    if @user.save
      flash[:success] = "User created "
      redirect_to admin_users_path
    else
      flash.now[:error] = "User not created."
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(safe_user_params)
      flash[:success] = "User updated."
      redirect_to admin_users_path
    else
      flash.now[:error] = "User was not updated"
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy && sign_out
      flash[:success] = "User deleted"
      redirect_to admin_users_path
    else
      flash[:error] = "User was not deleted"
      render 'show'
    end
  end

  private

  def safe_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :billing_id, :shipping_id)
  end
end
