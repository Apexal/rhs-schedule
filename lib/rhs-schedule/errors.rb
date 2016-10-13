class InvalidScheduleError < StandardError
    def initialize(msg='Invalid schedule text file!')
        super
    end
end