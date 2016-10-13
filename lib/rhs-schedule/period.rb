class Period
  attr_reader :start_time
  attr_reader :end_time

  def initialize(course, start_time, end_time, location)
    @course_title = course
    @start_time = start_time
    @end_time = end_time
    @location = location
  end

  def to_s
    "#{@course_title} in #{@location} for #{duration} minutes"
  end

  # Returns the duration of the period in minutes
  # @return [Integer] duration in minutes
  def duration
    ((@end_time - @start_time) * 24 * 60).to_i
  end
end