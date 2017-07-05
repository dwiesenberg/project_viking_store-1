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

  accepts_nested_attributes_for :order_contents, reject_if: :all_blank,
                                                allow_destroy: :true

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

  def weekly_revenue(weeks_ago)
    starting_sunday = Time.now.midnight - Time.now.wday - (7 * weeks_ago).days
    joins("JOIN order_contents ON orders.id = order_contents.order_id JOIN products ON order_contents.product_id = products.id").where(:checkout_date => (starting_sunday..(starting_sunday + 7.days))).sum("(order_contents.quantity * products.price)")
  end

  private

  def self.largest_value_since(date)
    result = select("orders.id, SUM(order_contents.quantity * products.price) AS value").
      joins("JOIN order_contents ON orders.id = order_contents.order_id JOIN products ON products.id = order_conents.product_id").
      where("checkout_date > ?", date.days.ago).
      order("value DESC").
      group("orders.id").
      first
      first ? first.value : 0
  end

  def self.all_time_largest_value
    result = select("orders.id, SUM(order_conents.quantity * products.price) AS value").
      joins("JOIN order_contents ON orders.id = order_conents.order_id JOIN products ON products.id = order_conents.product_id").
      where("checkout_date IS NOT NULL").
      order("value DESC").
      group("orders.id").
      first
      first ? first.value : 0
  end
end








  def self.order_by_days(days)
    if days == 0
      sql = "select count(*)
      from orders"
    else
      sql = "select count(*)
      from orders
      where created_at >= current_date - interval '" + days.to_s + " days'"
    end
    result =  ActiveRecord::Base.connection.exec_query(sql)
    if result.rows.count > 0
      return result.rows[0][0] || 0
    else
      return 0
    end
  end

  def self.highest_single_order(row, col)
    sql = "SELECT users.first_name, users.last_name, sum(order_contents.quantity * products.price) as total, orders.id
          FROM users join orders
          ON orders.user_id = users.id
          JOIN order_contents
          ON orders.id = order_contents.order_id
          JOIN products
          ON order_contents.product_id = products.id
          GROUP BY orders.id, users.last_name, users.first_name
          ORDER BY total DESC
          LIMIT 1"
    result =  ActiveRecord::Base.connection.exec_query(sql)
    if result.rows.count > 0
      return result.rows[row][col] || 0
    else
      return 0
    end
  end

  def self.hightest_life_value(row, col)
    sql = "SELECT t.first_name, t.last_name, sum(t.order_total) as total
          FROM (SELECT users.first_name, users.last_name, sum(order_contents.quantity * products.price) as order_total
          FROM users join orders
          ON orders.user_id = users.id
          JOIN order_contents
          ON orders.id = order_contents.order_id
          JOIN products
          ON order_contents.product_id = products.id
          GROUP BY users.last_name, users.first_name) as t
          GROUP BY t.last_name, t. first_name
          ORDER BY total DESC
          LIMIT 1"
    result =  ActiveRecord::Base.connection.exec_query(sql)
    if result.rows.count > 0
      return result.rows[row][col] || 0
    else
      return 0
    end
  end

  def self.highest_average_order(row,col)
    sql = "SELECT u.first_name, u.last_name, u.total/u.num_orders as avg
          FROM (SELECT t.first_name, t.last_name, t.num_orders, sum(t.order_total) as total
          FROM (SELECT users.first_name, users.last_name, sum(order_contents.quantity * products.price) as order_total, count(order_contents.id) as num_orders
          FROM users join orders
          ON orders.user_id = users.id
          JOIN order_contents
          ON orders.id = order_contents.order_id
          JOIN products
          ON order_contents.product_id = products.id
          GROUP BY users.last_name, users.first_name) as t
          GROUP BY t.last_name, t. first_name, t.num_orders) as u
          GROUP BY u.last_name, u.first_name, u.total, u.num_orders
          ORDER BY avg DESC
          LIMIT 1"
    result =  ActiveRecord::Base.connection.exec_query(sql)
    if result.rows.count > 0
      return result.rows[row][col] || 0
    else
      return 0
    end
  end

  def self.most_orders_places(row, col)
    sql = "SELECT users.first_name, users.last_name, count(orders.id) as num_orders
            FROM users join orders
            ON orders.user_id = users.id
            GROUP BY users.last_name, users.first_name, orders.id
            ORDER BY num_orders DESC
            LIMIT 1"
    result =  ActiveRecord::Base.connection.exec_query(sql)
    if result.rows.count > 0
      return result.rows[row][col] || 0
    else
      return 0
    end
  end

  def self.new_order_by_days(days)
    if days == 0
      sql  = "select count(*)
      from orders"
    else
      sql = "select count(*)
      from orders
      where created_at >= current_date - interval '" + days.to_s + " days'"
    end
    result =  ActiveRecord::Base.connection.exec_query(sql)
    if result.rows.count > 0
      return result.rows[0][0] || 0
    else
      return 0
    end
  end
end
