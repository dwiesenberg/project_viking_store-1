class Admin::OrdersController < AdminController

  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :set_user, only: [:show, :edit]

  def index
    if params[:user_id]
      if User.exists?(params[:user_id])
        @user = User.find(params[:user_id])
        @orders = Order.where(user_id: @user.id)
      else
        flash[:error] = "Invalid User Id"
        redirect_to admin_user_orders_path
      end
    else
      @orders = Order.all
    end
  end

  def show
  end

  def new
    @user = User.find(params[:user_id])
    @order = @user.orders.build
    3.times { @order.order_contents.build({quantity: nil}) }
  end

  def create
    @order = Order.new(safe_order_params)
    @order.checkout_date ||= Time.now

    if @order.save
      flash[:success] = "Order created."
      redirect_to admin_user_orders_path
    else
      flash.now[:error] = "Order creation failed."
      render 'new'
    end
  end

  def edit
    3.times { @order.order_contents.build({quantity: nil}) }
  end

  def update
    @order.checkout_date ||= Time.now if params[:order][:checked_out]
    if @order.update_attributes(safe_order_params)
      flash[:success] = "Order updated."
      redirect_to admin_user_orders_path
    else
      flash.now[:error] = "Order update failed."
      render 'edit'
    end
  end

  def destroy
    if @order.destroy
      flash[:success] = "Order deleted."
      redirect_to admin_user_orders_path
    else
      flash[:error] = "Order deletion failed."
      render 'show'
    end
  end

  private

  def safe_order_params
    params.require(:order).permit(:user_id, :billing_id, :shipping_id, :checkout_date, :credit_card_id, {:order_contents_attributes => [:id, :quantity, :_destroy, :order_id, :product_id]})
  end
end
