class Organizer < ApplicationRecord
  belongs_to :user
  belongs_to :competition

  validates :user_id, presence: true
  validates :competition_id, presence: true
end
