class League < ApplicationRecord
  has_many :general_managers, dependent: :destroy
  belongs_to :user
  validates :name, length: { maximum: 50 }
end
