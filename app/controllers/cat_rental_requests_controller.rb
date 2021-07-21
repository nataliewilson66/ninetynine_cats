class CatRentalRequestsController < ApplicationController
  before_action :require_user!, only: %i(approve, deny)
  before_action :require_cat_ownership!, only: %i(approve, deny)

  def new
    @rental_request = CatRentalRequest.new
    @cats = Cat.all
    render :new
  end

  def create
    @rental_request = CatRentalRequest.new(cat_rental_request_params)
    @rental_request.requester = current_user

    if @rental_request.save
      redirect_to cat_url(@rental_request.cat)
    else
      flash.now[:errors] = @rental_request.errors.full_messages
      render :new
    end
  end

  def approve
    current_cat_rental_request.approve!
    redirect_to cat_url(current_cat)
  end

  def deny
    current_cat_rental_request.deny!
    redirect_to cat_url(current_cat)
  end

  private
  def cat_rental_request_params
    params.require(:request).permit(:cat_id, :start_date, :end_date, :status)
  end

  def current_cat_rental_request
    @rental_request ||= CatRentalRequest.includes(:cat).find(params[:id])
  end

  def current_cat
    current_cat_rental_request.cat
  end

  def require_cat_ownership!
    return if current_user.owns_cat?(current_cat)
    redirect_to cats_url(current_cat)
  end

end