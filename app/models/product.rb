class Product < ApplicationRecord
  belongs_to :category

  has_many :order_contents
  has_many :orders, through: :order_conents

  validates :price,
            :presence => true,
            :allow_blank => false,
            :allow_nil => false,
            :nermericality => {:less_than_or_equal_to => 10_000}

  validates :name,
            :presence => true,
            :allow_blank => false,
            :allow_nil => false

  validates :category_id,
            :presence => true,
            :allow_blank => false,
            :allow_nil => false

  validates :sku,
            :presence => true,
            length: {maximum: 20},
            numericality: {is_integer: true}

  scope :of_category, ->(category_id){where(category_id: category_id)}

  def self.containing_only_category(category)
    joins(:category).where("products.category_id = ?", category.id)
  end

  def self.new_products(last_x_days = nil)
    if last_x_days
      where("created_at > ?", Time.now - last_x_days.days).count
    else
      count
    end
  end

end
