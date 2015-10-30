FactoryGirl.define do
  factory :order do
    user nil
    total { rand() * 1000 }
  end

end
