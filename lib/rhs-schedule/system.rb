require 'date'

require_relative 'scheduleday'
require_relative 'period'

# 05/25/16 08:50 AM
DATE_FORMAT = '%m/%d/%y'.freeze
TIME_FORMAT = '%I:%M %p'.freeze
DATETIME_FORMAT = "#{DATE_FORMAT} #{TIME_FORMAT}".freeze
EXCEPTIONS = ['0', '1', '2', '3', 'WEBEIM Scheduled', 'SIS Scheduled'].freeze

class ScheduleSystem
  attr_reader :schedule_days

  def initialize(path)
    @path = path
    @classdays = []
    @schedule_days = {}
    parse
  end

  def get_sd date
    if date.is_a? DateTime
      @schedule_days[date]
    else
      date = Date.strptime(date, DATE_FORMAT)
      @schedule_days[date]
    end
  end

  def today
    #false_date = Date.strptime('05/20/16', DATE_FORMAT)
    @classdays.find { |cd| cd.schedule_day == @schedule_days[Date.parse(Time.now.to_s)]}
    #@classdays.find { |cd| cd.schedule_day == @schedule_days[false_date] }
  end

  def parse
    sds = [] # Schedule day lines
    ps = [] # Period lines

    File.open(@path, 'r') do |f|
      f.each_line do |line|
        next if line.include? 'Start Date' or line.strip.empty?

        # Split the line and remove all the unnecessary values
        values = line.split("\t")

        # Determine schedule day or period
        if line.include? ' Day'
          # Use only date and schedule day
          vital = [values[0], values[4]]
          sds << vital
        elsif values.length == 10
          # Use only date, start time, end time, class name, and location
          vital = [values[0], values[1], values[3], values[4], values[5]]
          ps << vital
        end
      end
    end

    puts "Found #{ps.length} periods for #{sds.length} class days"

    sds.each { |values| handle_schedule_day_line values }
    handled = [] # Holds what schedules have been made
    @schedule_days.each do |date, sd|
      next if handled.include? sd

      lines = ps.find_all { |values| values[0] == date.strftime(DATE_FORMAT) }
      next if lines.empty?
      create_class_day sd, lines
      handled << sd
    end
  end

  def handle_schedule_day_line values
    date = Date.strptime(values[0], DATE_FORMAT)
    sd = values[1][0] # A Day -> A
    @schedule_days[date] = sd
  end

  def create_class_day sd, lines
    periods = []
    lines.each do |values|
      # [date, start time, end time, class name, location]
      course_title = values[3]
      start_time = DateTime.strptime(values[1], TIME_FORMAT)
      end_time = DateTime.strptime(values[2], TIME_FORMAT)
      location = values[4]

      periods << Period.new(course_title, start_time, end_time, location)
    end

    day = ScheduleDay.new(sd, periods)
    fill_periods day
    @classdays << day
  end

  # Take a just created periods list and fill in the holes (lunch and frees)
  def fill_periods(day)
    old = day.periods

    # AM Advisement isn't in schedule text file
    filled = [Period.new('Morning Advisement', DateTime.strptime('8:40 AM', TIME_FORMAT), DateTime.strptime('8:50 AM', TIME_FORMAT), 'Advisement')]

    last_end = filled.first.end_time # Don't use old.first since the day could start with a free period
    old.each do |p|
      filled << Period.new('Unstructured Time', last_end, p.start_time, 'Anywhere') if p.start_time != last_end # I <3 Ruby

      filled << p
      last_end = p.end_time
    end

    if filled.last.end_time.strftime('%I:%M %p') != '02:50 PM'
      end_time = DateTime.strptime('2:50 PM', TIME_FORMAT)
      filled << Period.new('Unstructured Time', filled.last.end_time, end_time, 'Anywhere')
    end

    # PM Advisement isn't in schedule text file
    filled << Period.new('Afternoon Advisement', DateTime.strptime('2:50 PM', TIME_FORMAT), DateTime.strptime('3:00 PM', TIME_FORMAT), 'Advisement')
    day.periods = filled
  end
end