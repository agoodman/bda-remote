class Heat < ApplicationRecord
  belongs_to :competition
  has_many :heat_assignments
  has_many :vessels, through: :heat_assignments
  has_many :players, through: :vessels
  has_many :records

  validates :competition_id, presence: true

  scope :for_stage, ->(stage) { where(stage: stage) }
  scope :not_started, -> { where(started_at: nil) }
  scope :started, -> { where("started_at is not null") }
  scope :not_ended, -> { where(ended_at: nil) }
  scope :ended, -> { where("ended_at is not null") }

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

  def leaders
    result = records.group_by(&:vessel_id).map { |k, e|
      {
          kills: e.map(&:kills).sum,
          deaths: e.map(&:deaths).sum,
          assists: e.map(&:assists).sum,
          hits_out: e.map(&:hits_out).sum,
          hits_in: e.map(&:hits_in).sum,
          dmg_out: e.map(&:dmg_out).sum,
          dmg_in: e.map(&:dmg_in).sum,
          name: (vessels.where(id: k).first.player.name rescue "-")
      }
    }
    max_hits_out = result.map { |e| e[:hits_out] }.max
    return result.sort_by { |e| 3*e[:kills] - 3*e[:deaths] + e[:assists] + 5*e[:hits_out]/max_hits_out }.reverse
  end

end
