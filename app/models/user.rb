class User < ApplicationRecord
  belongs_to :billing_address,
              class_name: "Address",
              :foreign_key => :billing_id

  belongs_to :shipping_address,
              class_name: "Address",
              :foreign_key => :shipping_id

  has_many :addresses
  has_many :orders
  has_many :credit_cards, dependent: :destroy
  has_many :products, through: :order_contents

  validates :first_name,
            :last_name,
            length: {maximum: 250},
            presence: true

  validates :email,
            presence: true,
            format: {with:/@/}

  accepts_nested_attributes_for :addresses,
                                :allow_blank => true,
                                :reject_if => :allow_blank

  def completed_orders
    orders.where.not(checkout_date: nil)
  end

  def last_checkout_date
    orders.where.not(checkout_date: nil).
    order("checkout_date DESC").
    pluck(:checkout_date).first || "n/a"
  end

  def name
    "#{first_name} #{last_name}"
  end

  def cart
    orders.find_by(checkout_date: nil)
  end

  def self.new_users(last_x_days = nil)
    if last_x_days
      where("created_at > ?", Time.now - last_x_days.days).count
    else
      count
    end
  end

  def self.top_order
    select("users.first_name AS user_first_name, users.last_name AS user_last_name, SUM(order_contents.quantity * products.price) AS value").
      joins("JOIN orders ON users.id = orders.user_id JOIN order_contents ON orders.id = order_contents.order_id JOIN products ON order_contents.product_id = products.id").
      where("orders.checkout_date IS NOT NULL").
      group("orders.id, user_last_name, user_first_name").
      order("value DESC").
      first
  end

  def self.order_values
    select("orders.id as oid, SUM(order_contents.quantity * products.price) AS value").
      joins("JOIN orders ON users.id = orders.user_id JOIN order_contents ON orders.id = order_contents.order_id JOIN products ON order_contents.product_id = products.id").
      group("oid")
  end

  def self.highest_lifetime
    select("users.first_name AS user_first_name, users.last_name AS user_last_name, SUM(order_contents.quantity * products.price) AS value").
      joins("JOIN orders ON users.id = orders.user_id JOIN order_contents ON orders.id = order_contents.order_id JOIN products ON order_contents.product_id = products.id").
      where("orders.checkout_date IS NOT NULL").
      group("users.id, user_last_name, user_first_name").
      order("value DESC").
      first
  end

  def self.highest_average_order
    joins("JOIN orders ON users.id = orders.user_id JOIN order_contents ON orders.id = order_contents.order_id JOIN products ON order_contents.product_id = products.id").
      where("orders.checkout_date IS NOT NULL").
      select("users.id AS user_id, users.first_name AS user_first_name, users.last_name AS user_last_name, (SUM(order_contents.quantity * products.price) / COUNT(DISTINCT orders.id)) AS value").
      group("users.id, user_last_name, user_first_name").
      order("value DESC").
      first
  end

  def self.most_orders
    select("users.first_name AS user_first_name, users.last_name AS user_last_name, COUNT(DISTINCT orders.id) AS orders_placed").
      joins("JOIN orders ON users.id = orders.user_id").
      where("orders.checkout_date IS NOT NULL").
      group("users.id, user_last_name, user_first_name").
      order("orders_placed DESC").
      first
  end

end
