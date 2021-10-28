module ActiveRecordExtensions
  def buckets_for(recent_records, days, now=Time.now)
    buckets = recent_records.map(&:created_at).group_by(&:at_end_of_day).map { |k,v| [k,v.count] }.to_h

    (0..days).each do |e|
      cutoff = (now - e.day).at_end_of_day
      unless buckets[cutoff]
        buckets[cutoff] = 0
      end
    end

    active_keys = buckets.keys.sort
    day_keys = active_keys.map { |e| e.strftime("%d %b") }
    day_counts = active_keys.map { |e| buckets[e] }
    [day_keys, day_counts]
  end
end
