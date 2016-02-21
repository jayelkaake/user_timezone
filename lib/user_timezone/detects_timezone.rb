require "active_support/concern"
require "user_timezone/timezone_detector"
module UserTimezone
  module DetectsTimezone
    extend ::ActiveSupport::Concern

    module ClassMethods
      def detects_timezone(options = {})
        cattr_accessor :timezone_detector
        self.timezone_detector = UserTimezone::TimezoneDetector.new(options)
        include LocalInstanceMethods
        case options[:on]
          when :before_save
            before_save :detect_timezone!
          when :before_create
            before_create :detect_timezone!
          else
            # Do nothing, but using switch statement
        end
      end
    end

    module LocalInstanceMethods
      ##
      # @return [String] Uses the configured address fields to return a timezone value such as "America/Chicago"
      #
      def detect_timezone
        self.class.timezone_detector.detect(self)
      end

      ##
      # Detects the timezone using the self.#detect_timezone then sets the value
      # into the local timezone field (as configured)
      # @see #detect_timezone
      #
      def detect_timezone!
        self.send(self.class.timezone_detector.options.as, self.detect_timezone)
      end

      ##
      # @return [String] Gets he GMT offset that ruby likes (such as -05:00) in +/-HH:MM form
      def utc_offset
        offset = self.class.timezone_detector.detect(self, 'utc_offset')
        return nil if offset.nil?
        offset_val = offset.to_i
        (offset_val < 0 ? '-' : '+') + Time.at(offset_val.abs.to_i).utc.strftime("%H:%M")
      end
      alias_method :gmt_offset, :utc_offset

      ##
      # @return [Time] What time is it for this user?
      def current_time
        Time.now.utc.getlocal(utc_offset) unless utc_offset.nil?
      end

    end
  end
end

ActiveRecord::Base.send :include, UserTimezone::DetectsTimezone