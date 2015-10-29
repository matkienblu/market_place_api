require 'spec_helper'

describe User do
  # build mock data then test
  before { @user = FactoryGirl.build(:user) }

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should be_valid }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_confirmation_of(:password) }
  it { should allow_value('example@domain.com').for(:email) }

  describe 'when email is not present' do
    before { @user.email = " "}
    it { should_not be_valid }
  end

  # we test the user actually respond to this attribute
  it { should respond_to(:auth_token) }

  # we test the auth_token is unique
  it { should validate_uniqueness_of(:auth_token)}

  it { should have_many(:products) }

  describe "#generate_authentication_token!" do
    it "generates a unique token" do
      @token = "anuniquetoken123"
      Devise.stub(:friendly_token).and_return(@token)
      @user.generate_authentication_token!
      expect(@user.auth_token).to eql @token
    end

    it "generates another token when one already has been taken" do
      existing_user = FactoryGirl.create(:user, auth_token: "auniquetoken123")
      @user.generate_authentication_token!
      expect(@user.auth_token).not_to eql existing_user.auth_token
    end

  end

  describe "#products association" do
    before do
      @user.save
      3.times { FactoryGirl.create :product, user: @user}
    end

    it "destroy the associated products on self destruct" do
      products = @user.products
      @user.destroy
      products.each do |product|
        expect(Product.find(product)).to raise_error ActiveRecord::RecordNotFound
      end

    end
  end
end


