require 'json'
require 'logger'
require 'metakgs/cache/null'
require 'metakgs/error'
require 'metakgs/http/header'
require 'metakgs/http/response'
require 'metakgs/client/archives'
require 'metakgs/client/top100'
require 'metakgs/client/tournament'
require 'metakgs/client/tournaments'
require 'metakgs/version'
require 'net/http'
require 'uri'

module MetaKGS
  class Client

    include MetaKGS::Client::Archives
    include MetaKGS::Client::Top100
    include MetaKGS::Client::Tournament
    include MetaKGS::Client::Tournaments

    NET_HTTP_EXCEPTIONS = [
      EOFError,
      Errno::ECONNABORTED,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::EINVAL,
      Errno::ENETUNREACH,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      SocketError,
      Zlib::GzipFile::Error,
    ]

    attr_accessor :cache
    attr_accessor :shared_cache
    attr_accessor :logger
    attr_accessor :read_timeout
    attr_accessor :open_timeout
    attr_accessor :api_endpoint

    def initialize( args = {} )
      @api_endpoint = args[:api_endpoint] || 'http://metakgs.org/api'
      @read_timeout = args[:read_timeout]
      @open_timeout = args[:open_timeout]
      @logger = args[:logger] || Logger.new( STDERR )
      @cache = args[:cache] || MetaKGS::Cache::Null.new
      @shared_cache = args[:shared_cache] || false
      self.default_header = args[:default_header] if args[:default_header]
      self.agent = args[:agent] if args.has_key? :agent
    end

    def default_header
      @default_header ||= MetaKGS::HTTP::Header.new({
        'User-Agent' => "MetaKGS Ruby Gem #{MetaKGS::VERSION}",
      })
    end

    def default_header=( value )
      @default_header = MetaKGS::HTTP::Header.new( value )
    end

    def agent
      default_header['User-Agent']
    end

    def agent=( value )
      default_header['User-Agent'] = value
    end

    def get_json( path )
      response = get path
      content_type = response.content_type || ''
      return JSON.parse(response.body) if content_type == 'application/json'
      raise MetaKGS::Error, 'Not a JSON response'
    end

    def get( path )
      url = path =~ /^https?:\/\// ? path : uri_for(path)
      cached = cache.fetch url

      return cached if cached and cached.fresh?

      header = default_header.dclone
      header['If-None-Match'] = cached.etag if cached and cached.has_etag?
      header.if_modified_since = cached.last_modified if cached and cached.has_last_modified?

      begin
        response = http_get URI(url), header
      rescue *NET_HTTP_EXCEPTIONS => evar
        raise MetaKGS::Error::ConnectionFailed, evar
      rescue Timeout::Error => evar
        raise MetaKGS::Error::TimeoutError, evar
      end

      case response
      when Net::HTTPOK
        res = create_response response
      when Net::HTTPNotModified
        res = cached.merge_304 response
      when Net::HTTPNotFound
        raise MetaKGS::Error::ResourceNotFound
      when Net::HTTPClientError, Net::HTTPServerError
        raise MetaKGS::Error::ClientError
      else
        raise MetaKGS::Error, "don't know how to handle #{response}"
      end

      if res.cacheable? shared_cache
        cache.store url, res
      else
        cache.delete url
      end

      res
    end

    def uri_for( path )
      File.join api_endpoint, path
    end

  private

    def create_response( response )
      MetaKGS::HTTP::Response.new( response )
    end

    def http_get( *args )
      http_request :get, *args
    end

    def http_request( method, url, header = default_header )
      http = Net::HTTP.new( url.host, url.port )
      http.read_timeout = read_timeout if read_timeout
      http.open_timeout = open_timeout if open_timeout
      http.set_debug_output logger if logger.debug?
      http.send method, url.path, header.to_hash
    end

  end
end

