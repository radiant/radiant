module LoggingTestHelper
  
  # used by tests
  def log_matches(regexp)
    result = false
    open(RAILS_ROOT + '/log/test.log') do |f|
      lines = f.readlines.to_s
      result = true if regexp.match(lines)
    end
    result
  end
  
  #used by specs
  def rails_log
    log = IO.read(RAILS_ROOT + '/log/test.log')
    log.should_not be_nil
    log 
  end
  
end