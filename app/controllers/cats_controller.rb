class CatsController < ApplicationController
  before_action :require_user!, only: %i(new create edit update)

  def index
    @cats = Cat.all

    render :index
  end

  def show
    @cat = Cat.find_by(id: params[:id])
    @requests = CatRentalRequest.where(cat_id: @cat.id).order(:start_date)

    if @cat
      render :show
    else
      redirect_to cats_url
    end
  end

  def new
    @cat = Cat.new
    render :new
  end

  def create
    @cat = Cat.new(cat_params)
    @cat.owner = current_user

    if @cat.save
      redirect_to cat_url(@cat)
    else
      flash.now[:errors] = @cat.errors.full_messages
      render :new
    end
  end

  def edit
    @cat = current_user.cats.find(params[:id])
    render :edit
  end

  def update
    @cat = current_user.cats.find(params[:id])

    if @cat.update_attributes(cat_params)
      redirect_to cat_url(@cat)
    else
      flash.now[:errors] = @cat.errors.full_messages
      render :edit
    end
  end

  private
  def cat_params
    params.require(:cat).permit(:name, :birth_date, :color, :sex, :description, :age)
  end
end