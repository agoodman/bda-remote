class Player < ApplicationRecord
  belongs_to :user
  has_many :vessels
  has_many :records, through: :vessels

  validates :name, presence: true

  def recent_competitions
    vessels.order("updated_at desc").limit(10).map(&:competition)
  end
end
