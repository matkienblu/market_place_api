FactoryGirl.define do
  factory :user do
    # this is a mock data - prepared by Test DB
    email {FFaker::Internet.email }
    password "12345678"
    password_confirmation "12345678"
  end

end
