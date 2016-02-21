require 'httparty'
module UserTimezone
  class TimezoneDetector
    def initialize(options = {})
      @options = options
    end

    def detect(object)
      api_uri = 'http://timezonedb.wellfounded.dev/api/v1'
      api_request_url = "#{api_uri}/timezones?"
      filters = []
      if @options[:using].present?
        using = @options[:using]
        if using.is_a?(Array)
          using.each do |filter_name|
            filters << ("#{filter_name}=" << object.send(filter_name))
          end
        else
          using.each do |local_name, filter_name|
            filters << ("#{filter_name}=" << object.send(local_name))
          end
        end
      end
      api_request_url << filters.join('&')
      puts "API URL: #{api_request_url}"
      results = HTTParty.get(api_request_url)
      if results.empty?
        nil
      else
        results.first['timezone']
      end
    rescue Exception => e
      nil
    end

  end
end