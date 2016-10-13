require_relative './rhs-schedule/system'
require 'json'

VERSION = '0.0.1'.freeze

path = ARGV.empty? ? 'resources/schedule.txt' : ARGV[0] 

abort "Cannot find schedule text file at '#{path}'. Please download it from http://intranet.regis.org/downloads/outlook_calendar_import/outlook_schedule_download.cfm." unless File.file? path

@schedule = ScheduleSystem.new path

puts 'Exporting schedule days to JSON'
File.open('resources/schedule_days.json','w') do |f|
  f.write(JSON.pretty_generate(@schedule.schedule_days))
end

def command_help(_)
  puts 'Help...?'
end

def command_exit(_)
  exit
end

# Menu
puts "Regis Schedule Parser v#{VERSION}"
loop do
  print '> '

  parts = gets.chomp.strip.split ' '
  command = parts.first
  args = parts.drop 1

  begin
    send("command_#{command}", args)
  rescue NoMethodError
    puts 'Unknown command.'
  rescue ArgumentError
    puts 'Error executing command.'
  end
end
