ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
# Lessens Debians need to edit.
require "rubygems" rescue nil

# Since Bundler is not really a 'must have' for Rails development just send off
# a warning and see if the sytem continues to load, the user can optionally use
# RADIANT_NOWARNINGS to disable it.

if File.file?(ENV['BUNDLE_GEMFILE'])
  begin
    require 'bundler/setup'
  rescue LoadError
    unless ENV['RADIANT_NOWARNINGS'] == true
      $stderr.puts 'WARNING: It seems you do not have Bundler installed.'
      $stderr.puts 'WARNING: You can install it by doing `gem install bundler`'
    end
  end
end
