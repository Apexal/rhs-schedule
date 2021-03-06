require 'date'
require 'json'

require_relative 'rhs-schedule/scheduleday'
require_relative 'rhs-schedule/period'
require_relative 'rhs-schedule/exports'
require_relative 'rhs-schedule/errors'

VERSION = '0.9.1'.freeze

# e.g. 05/25/16
DATE_FORMAT = '%m/%d/%y'.freeze

# e.g. '08:50 AM' 
TIME_FORMAT = '%I:%M %p'.freeze

# e.g. '05/25/16 08:50 AM'
DATETIME_FORMAT = "#{DATE_FORMAT} #{TIME_FORMAT}".freeze

# The list of values found in a valid schedule download that should be ignored
EXCEPTIONS = ['0', '1', '2', '3', 'WEBEIM Scheduled', 'SIS Scheduled'].freeze

class ScheduleSystem
  include Exports

  # Returns an hash mapping all school days' dates to their schedule day letter
  # @return [Hash] the date to string hash
  attr_reader :schedule_days

  # Return a hash mapping schedule day letters to their corresponding ScheduleDay objects
  # @return [Hash] the string to ScheduleDay hash
  attr_reader :class_days

  # Creates a new ScheduleSystem by parsing the schedule text file passed to it. 
  # If it cannot read the file or it detects that the format of the file is invalid the program aborts.
  #
  # @param path [String] the path to the text file (not the folder!) 
  def initialize(path, silent=false)
    @silent = silent
    puts "Initializing Schedule System v#{VERSION}" unless @silent
    abort "Cannot find schedule text file at '#{path}'. Please download it from http://intranet.regis.org/downloads/outlook_calendar_import/outlook_schedule_download.cfm." unless File.file? path

    @path = path
    @class_days = {}
    @schedule_days = {}
    parse
    super(self) # Initialize the exports with the parsed schedule
  end

  # Gets the schedule day of the date passed.
  #
  # @param date [Date, DateTime] the date
  # @return [String] the schedule day
  def get_sd date
    if date.is_a? DateTime
      @schedule_days[date]
    else
      date = Date.strptime(date, DATE_FORMAT)
      @schedule_days[date]
    end
  end

  # Displays formatted info on the current day, including it's schedule day and classes in order.
  #
  # @return [ScheduleDay, nil] The ScheduleDay object, or nil if today is not a school day.
  def today
    #false_date = Date.strptime('05/20/16', DATE_FORMAT)
    @class_days[@schedule_days[Date.parse(Time.now.to_s)]]
  end

  # Gets the the letter of the schedule day of the date passed.
  #
  # @param date [String, Date, DateTime] the date
  # @return [ScheduleDay, nil] the letter or nil if the date is not a school day
  def get_schedule_day(date)
    d = nil
    if date.is_a? String
      d = Date.strptime(date, DATE_FORMAT)
    elsif date.is_a? DateTime
      d = date.to_date
    end

    return @schedule_days[d]
  end


  # Gets the the periods and schedule day of the passed date.
  #
  # @param date [String, Date, DateTime]
  # @return [ScheduleDay, nil] the ScheduleDay object or nil if the date passed is not a school day
  def get_class_day(date)
    d = nil

    if date.is_a? String
      d = Date.strptime(date, DATE_FORMAT)
    elsif date.is_a? DateTime
      d = date.to_date
    end

    return @class_days[@schedule_days[d]]
  end

  # Gets the current period object of the currently ongoing class (if today is a school day).
  #
  # @return [Period, nil] the Period object of the current class or nil if not a school day or school is over
  def current_period
    now = DateTime.parse(Time.now.to_s)
    #now = DateTime.strptime('12:11 PM', TIME_FORMAT)
    if @schedule_days.key? Date.parse(Time.now.to_s)
      morning = DateTime.strptime('08:40 AM', TIME_FORMAT)
      afternoon = DateTime.strptime('02:50 PM', TIME_FORMAT)
      
      if now >= morning and now <= afternoon
        # Search for current period
        today.periods.each do |p|
          return p if now >= p.start_time and now <= p.end_time
        end
      end
    end

    # Not a school day
    return nil
  end

  private
    def check_valid_schedule lines
      # Check for headers
      first_line = lines.first.strip
      raise InvalidScheduleError, 'Correct headers are missing.' if first_line != 'Start Date	Start Time	End Date	End Time	Subject	Location	All day event	Reminder on/off	Show time as	Categories' 

      # Check length of file
      raise InvalidScheduleError, 'File has less than 200 lines.' if lines.length < 200

      # Check if there are period lines and schedule day lines
      expected = lines.length * 10 # Expected data over all split by tabs
      actual = 0
      lines.each { |l| actual += l.split("\t").length }
      raise InvalidScheduleError, 'Not all lines are valid.' unless expected == actual
      #raise InvalidScheduleError, 'Missing schedule day lines' unless lines
    end

    # Reads the schedule text file and parses each line to decide periods and schedule days.
    def parse
      sds = [] # Schedule day lines
      ps = [] # Period lines

      File.open(@path, 'r') do |f|
        lines = f.read.split("\r")

        check_valid_schedule lines
        
        lines.each do |line|
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

      puts "Found #{ps.length} periods for #{sds.length} class days" unless @silent

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
      @class_days[sd] = day
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
      day.set_periods(filled)
    end
end