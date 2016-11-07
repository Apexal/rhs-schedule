class ScheduleDay
  # Returns the letter of the schedule day for the ScheduleDay object.
  # @return [String] the letter
  attr_reader :schedule_day

  # Gets all of the periods in this schedule day.
  attr_reader :periods

  def initialize(sd, periods)
    @schedule_day = sd
    @periods = periods
  end
  
  # Sets the period list as given, after checking to make sure there are no holes in the schedule. If there are it returns false and does not
  # set the schedule.
  #
  # @param new_periods [Array<Period>] the new period list
  # @return [nil]
  def set_periods(new_periods)
    # Check start and end
    raise InvalidPeriodList, 'First and/or last periods are missing!' unless new_periods.first.start_time.strftime(TIME_FORMAT) == '08:40 AM' and new_periods.last.end_time.strftime(TIME_FORMAT) == '03:00 PM'
    
    # Check for gaps
    prev_time = '08:40 AM'
    new_periods.each do |p|
      if p.start_time.strftime(TIME_FORMAT) == prev_time
        prev_time = p.end_time.strftime(TIME_FORMAT)
        next
      end
      raise InvalidPeriodList, "There is a gap in the period list at #{p.start_time.strftime(TIME_FORMAT)}"
    end
    
    # No gaps, go ahead
    @periods = new_periods
  end
  
  # Returns short summary of schedule day, including letter, number of periods, and then a list of the periods.
  def to_s
    to_return = ["#{@schedule_day}-Day: #{@periods.length} periods"]
    @periods.each do |p|
      to_return << " -#{p.to_s}"
    end
    to_return << "\n"

    to_return.join("\n")
  end
  
  private
    def add_period(period)
      @periods << period
    end

    def sort_periods
      @periods.sort! { |a, b| a.start_time <=> b.start_time }
    end
end
