class Heat < ApplicationRecord
  belongs_to :competition
  has_many :heat_assignments
  has_many :vessels, through: :heat_assignments
  has_many :records

  validates :competition_id, presence: true

  def status
    if started_at.nil?
      "pending"
    elsif !started_at.nil? && ended_at.nil?
      "running"
    elsif !started_at.nil? && !ended_at.nil?
      "finished"
    else
      "invalid"
    end
  end

  def can_start?
    started_at.nil? && ended_at.nil?
  end  

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

  def can_reset?
    !started_at.nil? && ended_at.nil? && records.empty?
  end

  def reset!
    self.started_at = nil
    self.ended_at = nil
    self.save!
  end

  def running?
    !started_at.nil? && ended_at.nil?
  end
end
