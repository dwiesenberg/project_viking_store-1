class Category < ApplicationRecord
  has_many :products, depndent: :nullify

  validates :name,
            presence: true,
            uniqueness: true,
            allow_blank: false,
            allow_nil: false,
            length: {
              in: 4..16
            }
end
