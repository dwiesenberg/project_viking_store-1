class CreditCardsController < ApplicationController
  def destroy
    @credit_card = CreditCard.find(params[:id])
    if @credit_card.destroy
      flash[:success] = "You have deleted the card successfully"
    else
      flash[:error] = "There is something wrong. We can't delete that card"
    end
    redirect_to edit_order_path(0)
  end
end
