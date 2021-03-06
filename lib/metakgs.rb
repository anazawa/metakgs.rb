require 'metakgs/client'

module MetaKGS
  class << self

    def client
      @client = MetaKGS::Client.new unless defined? @client
      @client
    end

    def respond_to_missing?( method_name, include_private=false )
      client.respond_to?( method_name, include_private )
    end

  private
  
    def method_missing( method_name, *args, &block )
      return super unless client.respond_to?( method_name )
      client.send( method_name, *args, &block )
    end

  end
end

