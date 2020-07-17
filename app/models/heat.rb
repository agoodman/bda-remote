class Heat < ApplicationRecord
  belongs_to :competition
  has_many :heat_assignments
  has_many :vessels, through: :heat_assignments
  has_many :records

  validates :competition_id, presence: true

  def start!
    return unless started_at.nil? && ended_at.nil?
    self.started_at = Time.now
    self.save!
  end

  def stop!
    return unless !started_at.nil? && ended_at.nil?
    self.ended_at = Time.now
    self.save!
  end

  def running?
    !started_at.nil? && ended_at.nil?
  end
end
