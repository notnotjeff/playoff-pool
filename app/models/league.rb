class League < ApplicationRecord
  has_many :general_managers, dependent: :destroy
  belongs_to :user
end
