class Admin::ProductsController < AdminController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(safe_product_params)
    if @product.save
      flash[:success] = "Product created "
      redirect_to admin_products_path
    else
      flash.now[:error] = "Product creation failed."
      render 'new'
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    if @product.update_attributes(safe_product_params)
      flash[:success] = "Product updated "
      redirect_to admin_products_path
    else
      flash.now[:error] = "Product updated failed"
      render 'edit'
    end
  end

  def destroy
    if @product.destroy
      flash[:success] = "Product deleted."
      redirect_to admin_products_path
    else
      flash[:error] = "Product deletion failed."
      render 'show'
    end
  end

  private
  def set_product
    @product = Product.find(params[:id])
  end

  def safe_product_params
    params.require(:product).permit(:name, :sku, :price, :category_id)
  end
end
