class Period
  attr_reader :start_time
  attr_reader :end_time
  attr_reader :course_title
  attr_reader :location

  def initialize(course, start_time, end_time, location)
    @course_title = course
    @start_time = start_time
    @end_time = end_time
    @location = location
  end

  # Returns a short summary of the period including subject, location, and duration with times
  def to_s
    "#{@course_title} in #{@location} for #{duration} minutes (#{start_time} to #{end_time})"
  end

  # Returns the duration of the period in minutes
  # @return [Integer] duration in minutes
  def duration
    ((@end_time - @start_time) * 24 * 60).to_i
  end
end