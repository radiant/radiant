require 'radiant/config'
module LocalTime
  def adjust_time(time)
    if (tz_string = Radiant::Config["local.timezone"]) and 
        timezone = (ActiveSupport::TimeZone[tz_string] || ActiveSupport::TimeZone[tz_string.to_i]) 
      # adjust time 
      time.in_time_zone(timezone).time
    else 
      time 
    end 
  end 
end
