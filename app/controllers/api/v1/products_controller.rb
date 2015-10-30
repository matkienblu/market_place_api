class Api::V1::ProductsController < ApplicationController
  before_action :authenticate_with_token!, only: [:show, :index, :create]

  respond_to :json
  def show
    respond_with Product.find(params[:id])
  end

  def index
    respond_with Product.search(params)
  end

  def create
    product = current_user.products.build(product_params)
    if product.save
      render json: product, status: 201, location: [:api, product]
    else
      render json: { errors: product.errors }, status: 422
    end
  end

  def update
    begin
      @exist_product = Product.find_by!(id: params[:id],user_id: params[:user_id])
      if @exist_product.update(product_params)
        render json: @exist_product, status: 200, location: [:api, @exist_product]
      else
        render json: { errors: @exist_product.errors }, status: 422
      end
    rescue ActiveRecord::RecordNotFound
      render json: { errors: "Product is not found" }, status: 404
    end
  end

  def destroy
    Product.delete(params[:id])
    head 204
  end
  private
  def product_params
    params.require(:product).permit(:title, :price,:published)
  end
end
