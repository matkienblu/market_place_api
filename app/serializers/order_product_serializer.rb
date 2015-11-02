class OrderProductSerializer < ActiveModel::Serializer
  # remove embebed users
  def include_user?
    false
  end
end
