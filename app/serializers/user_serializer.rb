class UserSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :email,  :auth_token
  has_many :products
end
