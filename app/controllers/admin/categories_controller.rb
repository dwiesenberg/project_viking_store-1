class Admin::CategoriesController < AdminController

  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.all
  end

  def show
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(safe_category_params)
    if @category.save
      flash[:success] = "Category created."
      redirect_to admin_categories_path
    else
      flash.now[:error] = "Category creation failed."
      render 'new'
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    if @category.update_attributes(safe_category_params)
      flash[:success] = "Category updated."
      redirect_to admin_categories_path
    else
      flash.now[:error] = "Category update failed."
      render 'edit'
    end
  end

  def destroy
    if @category.destroy
      flash[:success] = "Category deleted."
      redirect_to admin_categories_path
    else
      flash[:error] = "Category deletion failed."
      render 'show'
    end
  end

  private
  def set_category
    @category = Category.find(params[:id])
  end

  def safe_category_params
    params.require(:category).permit(:name)
  end
end
