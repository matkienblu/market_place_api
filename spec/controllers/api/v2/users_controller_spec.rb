require 'spec_helper'

describe Api::V2::UsersController do
  # add Content-type for request

  # test for getting and user
  describe 'GET #index' do
    # create mock data before testing
    before(:each) do
      @user = FactoryGirl.create :user
      @user2 = FactoryGirl.create :user
      @user3 = FactoryGirl.create :user
      @arr_user = [@user, @user2, @user3]
      get :index
    end

    it 'returns 3 users' do
      user_response = json_response
      expect(user_response[:users].length).to eql @arr_user.length
    end
    # check status code
    it { should respond_with 200 }
  end


end
