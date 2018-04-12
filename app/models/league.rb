class League < ApplicationRecord
  has_many :general_managers, dependent: :destroy
  belongs_to :user
  validates :name, length: { maximum: 50 }
  before_create :have_playoffs_started

  private
    def have_playoffs_started
      throw :abort if Round.current_round > 0
    end
end
