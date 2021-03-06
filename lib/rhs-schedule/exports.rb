module Exports
    def initialize(schedule)
        @schedule = schedule
    end
    
    # Outputs the current schedule in JSON format to the path specified. (NOT YET IMPLEMENTED)
    def to_json(path, include_advisements=false, include_frees=false)
        puts "Not yet implemented."
    end

    # Exports the current schedule in CSV format (according to Google Calendar) to the path specified.
    # https://support.google.com/calendar/answer/37118?hl=en
    #
    # @param path [String] the path to export to (not directory!)
    # @param include_advisements [Boolean] whether or not to include AM/PM advisements in the export
    # @param include_frees [Boolean] whether or not to include free periods in the export
    def to_csv(path, include_advisements=false, include_frees=false)
        # https://support.google.com/calendar/answer/37118?hl=en
        # The format of the file is as follows:
        # Headers
        # 1 line per period in the school year
        # 1 line per schedule day in the school year

        headers = ['Subject', 'Start Date', 'Start Time', 'End Date', 'End Time', 'Location', 'All Day Event']
        
        csv_file = File.open(path, 'w')
        csv_file.puts(headers.join(","))

        # 1 line per period in year
        @schedule.schedule_days.each do |date, sd|
            date_str = date.strftime(DATE_FORMAT)
            periods = @schedule.class_days[sd].periods
            periods = periods.select { |p| p.course_title != 'Unstructured Time' } unless include_frees
            periods = periods.select { |p| p.course_title != 'Morning Advisement' and p.course_title != 'Afternoon Advisement' } unless include_advisements

            periods.each do |p|
                values = [p.course_title, date_str, p.start_time.strftime(TIME_FORMAT), date_str, p.end_time.strftime(TIME_FORMAT), p.location, 'False']
                csv_file.puts(values.join(","))
            end
        end

        @schedule.schedule_days.each do |date, sd|
            # 05/26/17		05/26/17		A Day		1	0	3	SIS Scheduled
            date_str = date.strftime(DATE_FORMAT)
            values = ["#{sd} Day", date_str, '', date_str, '', '', 'True']
            csv_file.puts(values.join(","))
        end

        csv_file.close

        puts "CSV schedule file exported to '#{path}'"
    end

    # Exports the current schedule in CSV format (according to MS Outlook) to the path specified.
    # The format is the exact same as the initally downloaded schedule file.
    #
    # @param path [String] the path to export to (not directory!)
    # @param include_advisements [Boolean] whether or not to include AM/PM advisements in the export
    # @param include_frees [Boolean] whether or not to include free periods in the export
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

    def export_schedule_days(path, separator="\t")
        headers = ['Date', 'Schedule Day']
        tsv_file = File.open(path, 'w')
        tsv_file.puts(headers.join(separator))
        @schedule.schedule_days.each do |date, letter|
            date_str = date.strftime(DATE_FORMAT)
            values = [date_str, letter]
            tsv_file.puts(values.join(separator))
        end

        tsv_file.close
        puts "schedule days exported to '#{path}'"
    end

    def classdays_to_tsv(path, include_advisements=false, include_frees=false)
        headers = ['Schedule Day', 'Subject', 'Start Time', 'End Time', 'Location']
        
        tsv_file = File.open(path, 'w')
        tsv_file.puts(headers.join("\t"))

        # 1 line per period in year
        @schedule.class_days.each do |letter, schedule_day|
            periods = schedule_day.periods
            periods = periods.select { |p| p.course_title != 'Unstructured Time' } unless include_frees
            periods = periods.select { |p| p.course_title != 'Morning Advisement' and p.course_title != 'Afternoon Advisement' } unless include_advisements

            periods.each do |p|
                values = [letter, p.course_title, p.start_time.strftime(TIME_FORMAT), p.end_time.strftime(TIME_FORMAT), p.location]
                tsv_file.puts(values.join("\t"))
            end
        end
        tsv_file.close

        puts "class days TSV schedule file exported to '#{path}'"
    end
end