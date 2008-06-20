# Redefined standard Rails tasks only in instance mode
unless File.directory? "#{RAILS_ROOT}/app"
  require 'rake/testtask'
  
  ENV['RADIANT_ENV_FILE'] = File.join(RAILS_ROOT, 'config', 'environment')
  
  [Dir["#{RADIANT_ROOT}/vendor/rails/railties/lib/tasks/*.rake"], Dir["#{RADIANT_ROOT}/vendor/plugins/rspec_on_rails/tasks/*.rake"]].flatten.each do |rake|
    lines = IO.readlines(rake)
    lines.map! do |line|
      line.gsub!('RAILS_ROOT', 'RADIANT_ROOT') unless rake =~ /(misc|rspec)\.rake$/
      case rake
      when /testing\.rake$/
        line.gsub!(/t.libs << (["'])/, 't.libs << \1' + RADIANT_ROOT + '/')
        line.gsub!(/t\.pattern = (["'])/, 't.pattern = \1' + RADIANT_ROOT + '/')
      when /databases\.rake$/
        line.gsub!(/migrate\((["'])/, 'migrate(\1' + RADIANT_ROOT + '/')
        line.sub!("db/schema.rb", "#{RAILS_ROOT}/db/schema.rb")
      when /rspec\.rake$/
        line.gsub!('RAILS_ROOT', 'RADIANT_ROOT') unless line =~ /:noop/
        line.gsub!(/FileList\[(["'])/, "FileList[\\1#{RADIANT_ROOT}/")
      end
      line
    end
    eval(lines.join("\n"), binding, rake)
  end
end         