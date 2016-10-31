class Period
  # The time (only) of day that the period starts at.
  # ex. '10:30 AM' or '02:40 PM'
  # @return [String] the time
  attr_reader :start_time

  # The time (only) of day that the period ends at.
  # ex. '10:30 AM' or '02:40 PM'
  # @return [String] the time
  attr_reader :end_time

  # The title of the course or event of the period.
  # @return [String] the title
  attr_reader :course_title

  # The location of the period without any preceding text.
  # e.g. '312' not 'Room 312'
  # @return [String] the location
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

  # Returns the duration of the period in minutes of the period
  # @return [Integer] duration in minutes
  def duration
    ((@end_time - @start_time) * 24 * 60).to_i
  end
end