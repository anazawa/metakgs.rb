require 'time'

module MetaKGS
  class Cache

    attr_reader :auto_purge

    def initialize( args = {} )
      @auto_purge = args.has_key?(:auto_purge) ? args[:auto_purge] : false
    end

    def get( url )
      raise "call to abstract method 'get'"
    end

    def set( url, response )
      raise "call to abstract method 'set'"
    end

    def purge
      raise "call to abstract method 'purge'"
    end

    def expired?( response )
      cache_control = response.get_fields('Cache-Control') || []
      max_age = cache_control.find { |token| token =~ /^max-age=(\d+)$/ } && $1
      !max_age || Time.now.gmtime > Time.parse(response['Date']) + max_age.to_i
    end

  end
end
