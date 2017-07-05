class Admin::AddressesController < AdminController
  before_action :set_address, only: [:show, :edit, :update, :destroy]

  def index
    if params[:user_id]
      if User.exixts?(params[:user_id])
        @user = User.find(params[:user_id])
        @addresses = Address.where(user_id: @user.id)
      else
        flash[:error] = "Invalid User Id"
        redirect_to admin_addresses_path
      end
    else
      @addresses = Address.all
    end
  end

  def show
    @user = @address.user
  end

  def new
    @address = Address.new(user_id: params[:user_id])
  end

  def create
    @address = Address.new(safe_address_params)
    if @address.save
      flash[:success] = "Address created"
      redirect_to admin_user_addresses_path(@address.user_id)
    else
      flash.now[:error] = "Address creation failed"
      render 'new'
    end
  end

  def edit
  end

  def update
    if @address.update_attributes(safe_address_params)
      flash[:success] = "Address updated"
      redirect_to admin_user_addresses_path
    else
      flash.now[:error] = "Address update failed"
      render 'edit'
    end
  end

  def destroy
    if @address.destroy
      flash[:success] = "Address deleted"
      redirect_to admin_user_addresses_path
    else
      flash[:error] = "Address deletion failed"
      render 'show'
    end
  end

  private

  def safe_address_params
    params.require(:address).permit(:street_address, :state_id, :city_id, :user_id, :zip_code)
  end

end
