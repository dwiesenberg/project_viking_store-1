class Admin::DashboardController < AdminController
  def index
    @all_time = nil

    #add extra days and it auto-generates new tables via partial
    @time_frames = [7, 30, @all_time]
    setup_overall_platform(@time_frames)

    @top_states = State.three_with_most_users
    @top_cities = City.three_with_most_users

    @top_order = User.top_order
    @highest_lifetime = User.highest_lifetime
    @highest_average = User.highest_average_order
    @most_orders = User.most_orders

    setup_time_series(0..6)
  end

  private

  def setup_overall_platform(time_frames)
    @new_users = {}
    @new_orders = {}
    @new_products = {}
    @revenue = {}
    @largest_order = {}

    time_frames.each do |day|
      @new_users[day] = User.new_users(day)
      @new_orders[day] = Order.new_orders(day)
      @new_products[day] = Product.new_products(day)
      @revenue[day] = OrderContent.revenue(day)
      @largest_order[day] = Order.largest_value(day)
    end
  end

  def setup_time_series(day_range)
    @order_days = []
    @daily_revenue = []
    @order_weeks = []
    @weekly_revenue = []

    day_range.each do |x|
      @order_days << Order.orders_on(x)
      @daily_revenue << Order.daily_revenue(x)
      @order_weeks << Order.orders_in(x)
      @weekly_revenue << Order.weekly_revenue(x)
    end
  end
end
