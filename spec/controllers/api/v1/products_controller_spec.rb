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
      product_response = json_response[:product]
      expect(product_response[:title]).to eql @product.title
    end

    it "has the user as an embeded object" do
      product_response = json_response[:product]
      expect(product_response[:user][:email]).to eql @product.user.email
    end

    it { should respond_with 200 }
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

    it { should respond_with 200 }
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        user = FactoryGirl.create :user
        @product_attributes = FactoryGirl.attributes_for :product
        api_authorization_header user.auth_token
        post :create, {user_id: user.id, product: @product_attributes}
      end
      it "renders the json for the product record just created" do
        product_response = json_response[:product]
        expect(product_response[:title]).to eql @product_attributes[:title]
      end

      it { should respond_with 201 }
    end
  end
  describe "POST #create not created" do
    context "when is not created"
    before(:each) do
      user = FactoryGirl.create :user
      @invalid_product_attributes = {title: "Smart TV", price: "haizz"}
      api_authorization_header user.auth_token
      post :create, {user_id: user.id, product: @invalid_product_attributes}
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
        put :update, {user_id: @user.id, id: @product.id, product: {title: @changed_title}}
      end
      it "renders the json for the product record just updated" do
        product_response = json_response[:product]
        expect(product_response[:title]).to eql @changed_title
      end

      it { should respond_with 200 }
    end
    context "when is not successfully updated, Product not found" do
      before(:each) do
        @changed_title = "LCD tivi"
        put :update, {user_id: 1, id: @product.id, product: {title: @changed_title}}
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
        put :update, {user_id: @user.id, id: @product.id, product: {price: @new_price}}
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
      delete :destroy, {user_id: @user.id, id: @product.id}
    end
    it "check exist product" do
      @find_product = Product.find_by(id: @product.id)
      expect(@find_product).to be_nil
    end
    it { should respond_with 204 }
  end

  describe ".filter_by_title" do
    before(:each) do
      @product1 = FactoryGirl.create :product, title: "Plasma TV"
      @product2 = FactoryGirl.create :product, title: "iPhone 6s"
      @product3 = FactoryGirl.create :product, title: "macbook pro"
      @product4 = FactoryGirl.create :product, title: "LCD TV"
      @product5 = FactoryGirl.create :product, title: "CD player"
    end

    context "when a 'TV' title pattern is sent" do
      it "returns 2 products matching" do
        expect(Product.filter_by_title('TV').size).to eql 2
      end
      it "returns the products matching" do
        expect(Product.filter_by_title("TV").sort).to match_array([@product1, @product4])
      end
    end
  end
  describe ".above_or_equal_to_price" do
    before(:each) do
      @product1 = FactoryGirl.create :product, price: 100
      @product2 = FactoryGirl.create :product, price: 130
      @product3 = FactoryGirl.create :product, price: 200
      @product4 = FactoryGirl.create :product, price: 50
      @product5 = FactoryGirl.create :product, price: 300
    end

    it "returns the products which are above or equal to the price" do
      expect(Product.above_or_equal_to_price(200).sort).to match_array([@product3, @product5])

    end
  end

  describe ".recent" do
    before(:each) do
      @product1 = FactoryGirl.create :product, price: 100
      @product2 = FactoryGirl.create :product, price: 50
      @product3 = FactoryGirl.create :product, price: 150
      @product4 = FactoryGirl.create :product, price: 99

      #we will touch some products to update them
      @product2.touch
      @product3.touch
    end

    it "returns the most updated records" do
      expect(Product.recent).to match_array([@product3, @product2, @product4, @product1])
    end
  end

  describe ".search" do
    before(:each) do
      @product1 = FactoryGirl.create :product, price: 100, title: "Plasma tv"
      @product2 = FactoryGirl.create :product, price: 50, title: "Videogame console"
      @product3 = FactoryGirl.create :product, price: 150, title: "MP3"
      @product4 = FactoryGirl.create :product, price: 99, title: "Laptop"
    end

    context "when title 'videogame' and '100' a min price are set" do
      it "returns an empty array" do
        search_hash = { keyword: "videogame", min_price: 100 }
        expect(Product.search(search_hash)).to be_empty
      end
    end

    context "when title 'tv', '150' as max price, and '50' as min price are set" do
      it "returns the product1" do
        search_hash = { keyword: "tv", min_price: 50, max_price: 150 }
        expect(Product.search(search_hash)).to match_array([@product1])
      end
    end

    context "when an empty hash is sent" do
      it "returns all the products" do
        expect(Product.search({})).to match_array([@product1, @product2, @product3, @product4])
      end
    end

    context "when product_ids is present" do
      it "returns the product from the ids" do
        search_hash = { product_ids: [@product1.id, @product2.id]}
        expect(Product.search(search_hash)).to match_array([@product1, @product2])
      end
    end
  end
end
