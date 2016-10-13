class ScheduleDay
  attr_reader :schedule_day

  attr_writer :periods
  attr_reader :periods

  def initialize(sd, periods)
    @schedule_day = sd
    @periods = periods
  end

  def add_period(period)
    @periods << period
  end

  def sort_periods
    @periods.sort! { |a, b| a.start_time <=> b.start_time }
  end

  def to_s
    to_return = ["#{@schedule_day}-Day: #{@periods.length} periods"]
    @periods.each do |p|
      to_return << " -#{p.to_s}"
    end
    to_return << "\n"

    to_return.join("\n")
  end
end
