class Order < ActiveRecord::Base
  # validata data
  validates :total,numericality: {greater_than_or_equal_to: 0}, presence: true
  validates :user_id, presence: true
  validates_with EnoughProductsValidator

  # relational
  belongs_to :user
  has_many :placements
  has_many :products, through: :placements

  # set default data
  before_validation :set_total!

  def set_total!
    self.total = 0
    placements.each do |placement|
      self.total += placement.product.price * placement.quantity
    end
  end

  def build_placements_with_product_ids_and_quantities(product_ids_and_quantities)
    product_ids_and_quantities.each do |product_id_and_quantity|
      id, quantity = product_id_and_quantity # [1,5]

      self.placements.build(product_id: id, quantity: quantity)
    end
  end

end
