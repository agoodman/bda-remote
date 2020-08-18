class Player < ApplicationRecord
  belongs_to :user
  has_many :vessels

  validates :name, presence: true
end
