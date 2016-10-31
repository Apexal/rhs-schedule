module Exports
    def initialize(schedule)
        @schedule = schedule
        puts 'Loaded exports'
    end

    # Outputs the current schedule in JSON format to the path specified.
    def to_json(path, include_advisements=false, include_frees=false)
        puts "Not yet implemented."
    end

    # Outputs the current schedule in TSV format in a .txt file at the specified path which can be used to import the new schedule into Outlook.
    def to_tsv(path, include_advisements=false, include_frees=false)
        # The format of the file is as follows:
        # Headers
        # 1 line per period in the school year
        # 1 line per schedule day in the school year

        headers = ['Start Date', 'Start Time', 'End Date', 'End Time', 'Subject', 'Location', 'All day event', 'Reminder on/off', 'Show time as', 'Categories']
        
        
        tsv_file = File.open(path, 'w')
        tsv_file.puts(headers.join("\t"))

        # 1 line per period in year
        @schedule.schedule_days.each do |date, sd|
            date_str = date.strftime(DATE_FORMAT)
            periods = @schedule.class_days[sd].periods
            periods = periods.select { |p| p.course_title != 'Unstructured Time' } unless include_frees
            periods = periods.select { |p| p.course_title != 'Morning Advisement' and p.course_title != 'Afternoon Advisement' } unless include_advisements

            periods.each do |p|
                # Example line format:
                # 09/12/16	09:50 AM	09/12/16	10:50 AM	Fine Arts 11 Art Practicum (1A) Prezioso	416	0	0	2	SIS Scheduled
                
                values = [date_str, p.start_time.strftime(TIME_FORMAT), date_str, p.end_time.strftime(TIME_FORMAT), p.course_title, p.location, 0, 0, 2, 'SIS Scheduled']
                tsv_file.puts(values.join("\t"))
            end
        end

        @schedule.schedule_days.each do |date, sd|
            # 05/26/17		05/26/17		A Day		1	0	3	SIS Scheduled
            date_str = date.strftime(DATE_FORMAT)
            values = [date_str, '', date_str, '', "#{sd} Day", '', 1, 0, 3, 'SIS Scheduled']
            tsv_file.puts(values.join("\t"))
        end

        tsv_file.close

        puts "TSV schedule file exported to '#{path}'"
    end
end