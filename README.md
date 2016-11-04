# rhs-schedule
### v0.9.0
A RubyGem that can parse the Regis Intranet schedule download so that it can be used in programs (such as displaying it correctly).

## How to Use
```ruby
require 'rhs-schedule'

# Initialize the schedule system by passing a path to the schedule text download from the Intranet
# (found at http://intranet.regis.org/downloads/outlook_calendar_import/outlook_schedule_download.cfm)
schedule = ScheduleSystem.new 'path/to/schedule.txt'

# Check out the wiki to see how to use it!

# Examples:
puts schedule.today

schedule.get_class_day('09/26/16').periods.each do |p|
    puts p.duration
end

schedule.export_schedule_days('schedule_days.tsv')
```
**Documentation is available at [http://www.rubydoc.info/github/Apexal/rhs-schedule/master/](http://www.rubydoc.info/github/Apexal/rhs-schedule/master/)**
