class InvalidScheduleError < StandardError
    def initialize(msg='Invalid schedule text file!')
        super
    end
end

class InvalidPeriodList < StandardError
    def initialize(msg='Invalid period list!')
        super
    end
end