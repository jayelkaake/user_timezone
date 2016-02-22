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

    attr_reader :options
    ##
    # @param [Hash] options (optional) Options hash... that's a bit weird to say.
    # Check out https://github.com/jayelkaake/user_timezone for more information
    # on options
    def initialize(options = {})
      @options = default_options.merge(options)
      @request_cache = {}
      @logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end

    ##
    # @param [Hash] object What is the subject that we are detecting the timezone for?
    #                      or alternatively, what is the hash?
    #                      This can be a hash or object, as long as it contains the attributes
    #                      that we want (like street, city, country, zip, etc) or has the attributes
    #                      mapped by the options array "using" key (see https://github.com/jayelkaake/user_timezone)
    # @param [String] what_to_detect What should be detected? (default: 'timezone') Also 'current_timestamp' also acceptable.
    #
    # @return [String] Timezone value or nil if no timezone was found for the given object.
    def detect(object, what_to_detect='timezone')
      request_url = api_request_url(object)
      results = @request_cache[request_url] ? @request_cache[request_url] : HTTParty.get(request_url)
      if results.empty?
        nil
      else
        results.first[what_to_detect]
      end
    rescue StandardException => e
      err e.inspect
      raise e if @options[:raise_errors]
      nil
    end


    ##
    # @return [Hash] default options for the timezone detector class
    def default_options
      {
          using: [:city, :state, :country, :zip],
          raise_errors: false,
          as: :timezone
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
        gen_array_attribute_filters(object, @options[:using])
      else
        gen_map_attribute_filters(object, @options[:using])
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
    def gen_array_attribute_filters(object, attributes)
      attributes.map { |filter_name| gen_object_filter(object, filter_name, filter_name) }
    end

    def gen_map_attribute_filters(object, map)
      map.map { |local_name, filter_name| gen_object_filter(object, local_name, filter_name) }
    end


    def gen_object_filter(object, local_name, filter_name)
      if object.is_a?(Hash)
        filter_val = object[local_name]
        ("#{filter_name}=" << URI::encode(filter_val)) unless filter_val.nil?
      elsif object.respond_to?(local_name)
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