source :rubygems

# This is the minimum of dependency required to run
# the radiant instance generator, which is (normally)
# the only time the radiant gem functions as an
# application. The instance has its own Gemfile, which
# requires radiant and therefore pulls in every
# dependency mentioned in radiant.gemspec.

gem "rails",   "2.3.14"
gem "sqlite3", "1.3.4"

# When radiant is installed as a gem you can run all of
# its tests and specs from an instance. If you're working
# on radiant itself and you want to run specs from the
# radiant root directory, uncomment the line below and
# run `bundle install`.

# gemspec

gem "radiant-clipped-extension", :git => "git://github.com/radiant/radiant-clipped-extension.git"

if ENV['TRAVIS']
  gemspec :development_group => :test
end
