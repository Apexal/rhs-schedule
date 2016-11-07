require './lib/rhs-schedule.rb'

Gem::Specification.new do |s|
	s.name			= 'rhs-schedule'
	s.version		= ScheduleSystem::VERSION
	s.date			= '2016-11-07'
	s.summary		= 'A RegisHS schedule parser.'
	s.description	= 'A RubyGem that parses Regis High School\'s Intranet schedule download.'
	s.files 		= Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
	s.require_path	= 'lib'
	s.authors		= ['Frank Matranga']
	s.email			= 'thefrankmatranga@gmail.com'
	s.license		= 'MIT'
end
