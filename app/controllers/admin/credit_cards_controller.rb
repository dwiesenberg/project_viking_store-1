class Admin::CreditCardsController < AdminController
  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end
  
  def destroy
  	@credit_card = CreditCard.find(params[:id])
    @credit_card.destroy
    redirect_to edit_order_path
  end
end
