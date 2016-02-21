require "active_support/concern"
require "user_timezone/timezone_detector"
module UserTimezone
  module DetectsTimezone
    extend ActiveSupport::Concern

    included do
    end

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
      def detect_timezone
        self.class.timezone_detector.detect(self)
      end

      def detect_timezone!
        self.timezone = self.detect_timezone
      end
    end
  end
end

ActiveRecord::Base.send :include, UserTimezone::DetectsTimezone