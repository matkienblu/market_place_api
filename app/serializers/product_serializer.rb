class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :price, :published, :quantity
  has_one :user
end
