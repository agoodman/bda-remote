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

  def started?
    !started_at.nil?
  end

  def ended?
    !started_at.nil? && !ended_at.nil?
  end

  def running?
    !started_at.nil? && ended_at.nil?
  end

  def duration
    ended_at - started_at rescue 0
  end

  def leaders
    result = records.group_by(&:vessel_id).map { |k, e|
      {
          wins: e.map(&:wins).sum,
          score: competition.metric.score_for_record(e.first),
          kills: e.map(&:kills).sum,
          deaths: e.map(&:deaths).sum,
          assists: e.map(&:assists).sum,
          death_order: e.map(&:death_order).sum,
          death_time: e.map(&:death_time).sum,
          hits_out: e.map(&:hits_out).sum,
          hits_in: e.map(&:hits_in).sum,
          dmg_out: e.map(&:dmg_out).sum,
          dmg_in: e.map(&:dmg_in).sum,
          mis_dmg_out: e.map(&:mis_dmg_out).sum,
          mis_dmg_in: e.map(&:mis_dmg_in).sum,
          mis_parts_out: e.map(&:mis_parts_out).sum,
          mis_parts_in: e.map(&:mis_parts_in).sum,
          ram_parts_out: e.map(&:ram_parts_out).sum,
          ram_parts_in: e.map(&:ram_parts_in).sum,
          roc_dmg_out: e.map(&:roc_dmg_out).sum,
          roc_dmg_in: e.map(&:roc_dmg_in).sum,
          roc_parts_out: e.map(&:roc_parts_out).sum,
          roc_parts_in: e.map(&:roc_parts_in).sum,
          waypoints: e.map(&:waypoints).sum,
          elapsed_time: e.map(&:elapsed_time).sum,
          deviation: e.map(&:deviation).sum,
          ast_parts_in: e.map(&:ast_parts_in).sum,
          name: (e.first.vessel.full_name rescue "-")
      }
    }
    return result.sort_by { |e| e[:score] }.reverse
  end

end
