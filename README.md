# rhs-schedule
A RubyGem that can parse the Regis Intranet schedule download so that it can be used in programs (such as displaying it correctly).

## How to Use
```ruby
require 'rhs-schedule'

# Initialize the schedule system by passing a path to the schedule text download from the Intranet
# (found at http://intranet.regis.org/downloads/outlook_calendar_import/outlook_schedule_download.cfm)
schedule = ScheduleSystem.new 'path/to/schedule.txt'

# Check out the wiki to see how to use it!
puts schedule.today
```
**Documentation is available at [http://www.rubydoc.info/github/Apexal/rhs-schedule/master/](http://www.rubydoc.info/github/Apexal/rhs-schedule/master/)**
