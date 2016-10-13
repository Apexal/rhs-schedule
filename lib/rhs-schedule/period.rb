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

  def duration
    ((@end_time - @start_time) * 24 * 60).to_i
  end
end