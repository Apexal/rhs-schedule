require 'minitest/autorun'
require_relative '../lib/rhs-schedule.rb'

class SystemTest < MiniTest::Unit::TestCase
    def test_fake_schedule
        
        puts 'Testing parser with invalid schedule file...'
        path = 'test/invalid_schedule.txt'

        assert_raises do
            schedule = ScheduleSystem.new path
        end
    end

    def test_parse
        default = '/home/frank/Downloads/fmatranga18_schedule_download.txt'.freeze
        puts "Enter path or leave empty for default ('#{default}'): "
        path = ((entered = gets.chomp).empty? ? default : entered) # I can't believe this worked to be honest
        
        schedule = ScheduleSystem.new path
    end
end