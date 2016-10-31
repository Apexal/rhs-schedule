module Exports
    def initialize(schedule)
        @schedule = schedule
        puts 'Loaded exports'
    end

    # Outputs the current schedule in JSON format to the path specified.
    def to_json(path, include_frees=false)
        puts "Not yet implemented."
    end

    # Outputs the current schedule in TSV format in a .txt file at the specified path which can be used to import the new schedule into Outlook.
    def to_tsv(path, include_frees=false)
        # The format of the file is as follows:
        # Headers
        # 1 line per period in the school year
        # 1 line per schedule day in the school year

        headers = ['Start Date', 'Start Time', 'End Date', 'End Time', 'Subject', 'Location', 'All day event', 'Reminder on/off', 'Show time as', 'Categories']
        
        
        tsv_file = File.open(path, 'w')
        tsv_file.puts(headers.join("\t"))

        # 1 line per period in year
        @schedule.schedule_days.each do |date, sd|
            puts "#{date} | #{sd} | #{@schedule.class_days.find { |cd| cd.schedule_day == sd }.periods.length}"
        end

        tsv_file.close

        puts "TSV schedule file exported to '#{path}'"
    end
end