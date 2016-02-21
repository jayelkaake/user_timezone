require "user_timezone/version"

module UserTimezone

  if defined?(Rails)
    require 'user_timezone/detects_timezone'
  end

end