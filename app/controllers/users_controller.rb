class UsersController < ApplicationController
  def edit
  end

  def update
    if current_user.update(user_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  def show
    @parents = Category.where(ancestry: nil)
    @user = User.find(params[:id])
    if user_signed_in? && current_user.id == @user.id
      @products = @user.products.order("created_at DESC")
    else
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
