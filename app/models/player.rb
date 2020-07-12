class Player < ApplicationRecord
  has_many :vessels

  validates :name, presence: true
end
