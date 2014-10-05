require 'time'

module MetaKGS
  module Cache

    def get( url )
      raise "call to abstract method 'get'"
    end

    def set( url, response )
      raise "call to abstract method 'set'"
    end

    def expired?( response )
      cache_control = response.get_fields('Cache-Control') || []
      max_age = cache_control.find { |token| token =~ /^max-age=(\d+)$/ } && $1
      !max_age || Time.now > Time.parse(response['Date']) + max_age.to_i
    end

  end
end
