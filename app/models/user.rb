class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :teams, foreign_key: "user_id", class_name: "GeneralManager", dependent: :destroy
  has_many :leagues, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  def name
    return "#{self.first_name} #{self.last_name}"
  end
end
