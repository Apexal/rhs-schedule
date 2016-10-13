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
        puts "Not yet implemented."
    end
end