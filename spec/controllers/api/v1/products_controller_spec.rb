require 'spec_helper'

describe Api::V1::ProductsController do
  describe "GET #show" do
    before(:each) do
      user = FactoryGirl.create :user
      api_authorization_header user.auth_token
      @product = FactoryGirl.create :product
      get :show, id: @product.id
    end

    it "returns the information" do
      product_response = json_response
      expect(product_response[:title]).to eql @product.title
    end

    it { should respond_with 200}
  end

  describe "GET #index" do
    before(:each) do
      user = FactoryGirl.create :user
      api_authorization_header user.auth_token
      4.times { FactoryGirl.create :product }
      get :index
    end

    it "return 4 records from the db" do
      products_response = json_response
      expect(products_response[:products].size).to eql 4
    end

    it { should respond_with 200}
  end

  describe "POST #create" do
    context "when is successfully created" do
       before(:each) do
         user = FactoryGirl.create :user
         @product_attributes = FactoryGirl.attributes_for :product
         api_authorization_header user.auth_token
         post :create, {user_id: user.id,product: @product_attributes }
       end
       it "renders the json for the product record just created" do
         product_response = json_response
         expect(product_response[:title]).to eql @product_attributes[:title]
       end

       it { should respond_with 201 }
    end
  end
  describe "POST #create not created" do
    context "when is not created"
      before(:each) do
        user = FactoryGirl.create :user
        @invalid_product_attributes = { title: "Smart TV", price:"haizz"}
        api_authorization_header user.auth_token
        post :create, {user_id: user.id, product: @invalid_product_attributes }
      end

      it "renders an errors json" do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it "renders an detail error " do
        product_response = json_response
        expect(product_response[:errors][:price]).to include "is not a number"
      end

      it { should respond_with 422 }

  end


  describe "PUT/PATCH #update" do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
    end

    context "when is successfully updated" do
      before(:each) do
        @changed_title = "LCD tivi"
        put :update, {user_id: @user.id, id: @product.id, product: {title: @changed_title } }
      end
      it "renders the json for the product record just updated" do
        product_response = json_response
        expect(product_response[:title]).to eql @changed_title
      end

      it { should respond_with 200 }
    end
    context "when is not successfully updated, Product not found" do
      before(:each) do
        @changed_title = "LCD tivi"
        put :update, {user_id: 1, id: @product.id, product: {title: @changed_title } }
      end
      it "renders the json for the product record just updated" do
        product_response = json_response
        expect(product_response[:errors]).to include "not found"
      end

      it { should respond_with 404 }
    end

    context "when is not successfully updated, price" do
      before(:each) do
        @new_price = "aaa"
        put :update, {user_id: @user.id, id: @product.id, product: {price: @new_price } }
      end
      it "renders the json for the product record just updated" do
        product_response = json_response
        expect(product_response[:errors]).to_not be_nil
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, { user_id: @user.id, id: @product.id }
    end
    it "check exist product" do
      @find_product = Product.find_by(id: @product.id)
      expect(@find_product).to be_nil
    end
    it { should respond_with 204}
  end
end
