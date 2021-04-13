class Player < ApplicationRecord
  belongs_to :user
  has_many :vessels
  has_many :records, through: :vessels

  validates :user_id, presence: true
  validates :name, presence: true

  scope :human, -> { where(is_human: true) }
  scope :npc, -> { where(is_human: false) }

  def recent_competitions
    vessels.order("updated_at desc").map(&:competitions).flatten.take(10)
  end
end
