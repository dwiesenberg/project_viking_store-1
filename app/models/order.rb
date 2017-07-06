class Order < ApplicationRecord
  belongs_to :user,
              foreign_key: :user_id
  belongs_to :shipping_address,
              foreign_key: :shipping_id,
              class_name: "Address"
  belongs_to :billing_address,
              foreign_key: :billing_id,
              class_name: "Address"
  belongs_to :credit_car
  has_many :order_contents
  has_many :products, through: :order_contents

  validates :user_id,
            presence: true,
            numericality: {is_integer: true}

  def date_placed
    checkout_date && order.id ? checkout_date.strftime("%Y-%m-%d") : nil
  end

  def quantity
    order_contents.sum(:quantity)
  end

  def value
    products.sum("quantity * price")
  end

  def checked_out?
    checkout_date.present?
  end

  def self.checked_out
    where("checkout_date IS NOT NULL")
  end

  def self.checked_out_since(date)
    where("checkout_date > ?", date.days.ago)
  end

  def self.carts
    where(checkout_date: nil)
  end

  def self.new_orders(last_x_days = nil)
    if last_x_days
      checked_out_since(last_x_days).count
    else
      checked_out.count
    end
  end

  def self.largest_value(last_x_days = nil)
    if last_x_days
      largest_value_since(last_x_days)
    else
      all_time_largest_value
    end
  end

  def self.orders_on(days_ago)
    where(:checkout_date => ((Time.now.midnight - days_ago.days)..(Time.now.midnight + 1.days - days_ago.days))).size
  end

  def self.daily_revenue(days_ago)
    joins("JOIN order_contents ON orders.id = order_contents.order_id JOIN products ON order_contents.product_id = products.id").where(:checkout_date => ((Time.now.midnight - days_ago.days)..(Time.now.midnight + 1.days - days_ago.days))).sum("(order_contents.quantity * products.price)")
  end

  def self.orders_in(weeks_ago)
    starting_sunday = Time.now.midnight - Time.now.wday - (7 * weeks_ago).days
    where(:checkout_date => (starting_sunday..(starting_sunday + 7.days))).size
  end

  def self.weekly_revenue(weeks_ago)
    starting_sunday = Time.now.midnight - Time.now.wday - (7 * weeks_ago).days
    joins("JOIN order_contents ON orders.id = order_contents.order_id JOIN products ON order_contents.product_id = products.id").where(:checkout_date => (starting_sunday..(starting_sunday + 7.days))).sum("(order_contents.quantity * products.price)")
  end

  private

  def self.largest_value_since(date)
   select("orders.id, SUM(order_contents.quantity * products.price) AS value").
     from("orders").
     joins("JOIN order_contents ON orders.id = order_contents.order_id JOIN products ON products.id = order_contents.product_id").
     where("checkout_date > ?", date.days.ago).
     order("value DESC").
     group("orders.id").
     first
     first ? first.value : 0
  end

  def self.all_time_largest_value
    "commented out"
    # select("orders.id, SUM(order_conents.quantity * products.price) AS value").
    #   from("orders").
    #   joins("JOIN order_contents ON orders.id = order_conents.order_id JOIN products ON products.id = order_conents.product_id").
    #   where("checkout_date IS NOT NULL").
    #   order("value DESC").
    #   group("orders.id").
    #   first
    #   first ? first.value : 0
  end
end
