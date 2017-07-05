class Address < ApplicationRecord
  belongs_to :user
  belongs_to :state
  belongs_to :city

  has_many :orders_billed_here,
            class_name: "Order",
            foreign_key: :billing_id

  has_many :orders_shipped_here,
            class_name: "Order",
            foreign_key: :shipping_id

  validates :street_address, length: {maximum: 128},
                            presence: true

  validates :zip_code, numericality: {only_integer: true},
                            presence: true,
                            length: {is: 5}

  validates :city_id, :state_id,
                      numericality: {only_integer: true},
                      presence: true

  def full_address
    "#{street_address}, #{city.name}, #{state.name} #{zip_code}"
  end
end
