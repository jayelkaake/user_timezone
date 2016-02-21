require 'httparty'
require 'open-uri'
require 'logger'
module UserTimezone
  ##
  # The timezone detector class takes in smoe options, then when given
  # an object (user, contact, account, whatever) that has address information
  # returns back the timezone for that person.
  #
  class TimezoneDetector
    ##
    # @param [Hash] options (optional) Options hash... that's a bit weird to say.
    # Check out https://github.com/jayelkaake/user_timezone for more information
    # on options
    def initialize(options = {})
      @options = default_options.merge(options)
      @logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end

    ##
    # @param [Hash] object What is the subject that we are detecting the timezone for?
    #                      or alternatively, what is the hash?
    #                      This can be a hash or object, as long as it contains the attributes
    #                      that we want (like street, city, country, zip, etc) or has the attributes
    #                      mapped by the options array "using" key (see https://github.com/jayelkaake/user_timezone)
    #
    # @return [String] Timezone value or nil if no timezone was found for the given object.
    def detect(object)
      results = HTTParty.get(api_request_url(object))
      if results.empty?
        nil
      else
        results.first['timezone']
      end
    rescue Exception => e
      err e.inspect
      raise e if @options[:raise_errors]
      nil
    end

    ##
    # @return [Hash] default options for the timezone detector class
    def default_options
      {
          using: [:city, :state, :country, :zip],
          raise_errors: false
      }
    end


    ##
    # Gets the API request URL with the search parameters
    #
    # @param [Hash] object What is the subject that we are detecting the timezone for?
    #                      or alternatively, what is the hash?
    #                      This can be a hash or object, as long as it contains the attributes
    #                      that we want (like street, city, country, zip, etc) or has the attributes
    #                      mapped by the options array "using" key (see https://github.com/jayelkaake/user_timezone)
    #
    # @return [String] api request URL
    #
    def api_request_url(object)
      api_uri = 'http://timezonedb.wellfounded.ca/api/v1'
      api_request_url = "#{api_uri}/timezones?"
      api_request_url << get_filters(object).join('&')
      log "Making request to #{api_request_url} for timezone."
      api_request_url
    end


    ##
    # Gets the API request filter parts
    #
    # @param [Hash] object What is the subject that we are detecting the timezone for?
    #                      or alternatively, what is the hash?
    #                      This can be a hash or object, as long as it contains the attributes
    #                      that we want (like street, city, country, zip, etc) or has the attributes
    #                      mapped by the options array "using" key (see https://github.com/jayelkaake/user_timezone)
    #
    # @return [Array] Gets an array of field_name=value filters for the search
    #
    def get_filters(object)
      if @options[:using].is_a?(Array)
        get_array_attribute_filters(object, @options[:using])
      else
        get_map_attribute_filters(object, @options[:using])
      end
    end

    ##
    # Gets the API request URL with the search parameters
    #
    # @param [Hash] object What is the subject that we are detecting the timezone for?
    #                      or alternatively, what is the hash?
    #                      This can be a hash or object, as long as it contains the attributes
    #                      that we want (like street, city, country, zip, etc) or has the attributes
    #                      mapped by the options array "using" key (see https://github.com/jayelkaake/user_timezone)
    # @param [Hash] attributes Attributes to use in generating filters
    # @return [String] api request URL
    #
    def get_array_attribute_filters(object, attributes)
      filters = []
      attributes.each do |filter_name|
        filters << get_object_filter(object, filter_name, filter_name)
      end
      filters
    end

    def get_map_attribute_filters(object, map)
      filters = []
      map.each do |local_name, filter_name|
        filters << get_object_filter(object, local_name, filter_name)
      end
      filters
    end


    def get_object_filter(object, local_name, filter_name)
      if object.respond_to? (local_name)
        filter_val = object.send(local_name)
        ("#{filter_name}=" << URI::encode(filter_val)) unless filter_val.nil?
      else
        ''
      end
    end

    ##
    # Logs out as 'info' level using whatever logger the system is using
    #
    def log(msg)
      @logger.info("UserTimezone::TimezoneDetector - #{msg}") if @options[:log]
    end

    ##
    # Log out an error using the system's logger.
    #
    # @param [Exception] e exception or error encountered to send to the logger
    def err(e)
      @logger.error(e)
    end

  end
end