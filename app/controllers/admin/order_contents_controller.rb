class Admin::OrderContentsController < AdminController
  def index
  end

  def show
  end

  def new
  end

  def create
    if Purchase.create(create_purchase_params.values)
      flash[:success] = "New contents added to order."
      redirect_to orders_path
    else
      flash.now[:error] = "Contents were not added to order."
      render 'show'
    end
  end

  def edit
  end

  def update
    if Purchase.update(update_purchase_params.keys, update_purchase_params.values)
      flash[:success] = "Order contents updated."
      redirect_to orders_path
    else
      flash.now[:error] = "Order contents update failed."
      render 'show'
    end
  end

  def destroy
  end

  private

  def update_purchase_params
    params.require(:purchases)
  end

end
