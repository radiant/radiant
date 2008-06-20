require 'radiant/config'
module LocalTime
  def adjust_time(time)
    if (tz_string = Radiant::Config["local.timezone"]) and 
        timezone = (TimeZone[tz_string] || TimeZone[tz_string.to_i]) 
      # adjust time 
      timezone.adjust(time)
    else 
      time 
    end 
  end 
end
