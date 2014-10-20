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
require 'time'
require 'uri'

module MetaKGS
  # Public: TBD
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

    # Public: Gets or sets a cache object associated with this client.
    # The cache object must either inherit from MetaKGS::Cache or implement
    # all of #fetch, #store, #delete and #keys methods. Defaults to
    # MetaKGS::Cache::Null.
    attr_accessor :cache

    # Public: Should @cache act like a "shared cache" according
    # to the definition in RFC 7234? Defaults to false.
    attr_accessor :shared_cache

    # Public: Gets or sets a Logger object which is used to log
    # requests and responses.
    attr_accessor :logger

    # Public: Number of seconds to wait for one block to be read
    # by this user agent. Defaults to 60 seconds.
    attr_accessor :read_timeout

    # Public: Number of seconds to wait for the connection to open.
    # Defaults to nil.
    attr_accessor :open_timeout

    # Public: Base URL for API requests. Defaults to http://metakgs.org/api.
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

    # Public: Gets a header object that will provide default header
    # values for any requests sent.
    #
    #   agent = client.default_header['User-Agent']
    #   client.default_header['User-Agent'] = 'MyAgent/0.0.1'
    #
    def default_header
      @default_header ||= MetaKGS::HTTP::Header.new({
        'User-Agent' => "MetaKGS Ruby Gem #{MetaKGS::VERSION}",
      })
    end

    # Public: Replaces @default_header with the given header Hash.
    #
    #   client.default_header({
    #     'User-Agent' => 'MyAgent/0.0.1'
    #   })
    #
    def default_header=( value )
      @default_header = MetaKGS::HTTP::Header.new( value )
    end

    # Public: A shortcut for:
    #
    #   client.default_header['User-Agent']
    #
    def agent
      default_header['User-Agent']
    end

    # Public: A shortcut for:
    #
    #   client.default_header['User-Agent'] = value
    #
    def agent=( value )
      default_header['User-Agent'] = value
    end

    def get_json( path )
      response = get uri_for(path)
      content_type = response.content_type || ''
      return JSON.parse(response.body) if content_type == 'application/json'
      raise MetaKGS::Error, 'Not a JSON response'
    end

    def get( path )
      url = uri_for path
      cached = cache.fetch url

      return cached if cached and cached.fresh?

      header = default_header.dclone
      header.if_none_match = cached.etag if cached and cached.has_etag?
      header.if_modified_since = cached.last_modified if cached and cached.has_last_modified?

      response = http_get URI(url), header

      case response
      when Net::HTTPOK
        res = MetaKGS::HTTP::Response.new( response )
      when Net::HTTPAccepted
        if response.key? 'Retry-After'
          delay = response['Retry-After']
          delay = ( Time.httpdate(delay) - Time.now ).to_i if delay !~ /^\d+$/
          raise MetaKGS::Error::TimeoutError, "retry after #{delay} seconds"
        else
          raise MetaKGS::Error::TimeoutError, response
        end
      when Net::HTTPNotModified
        res = cached.merge_304 response
      else
        raise MetaKGS::Error, "don't know how to handle #{response}"
      end

      return res unless res.cacheable_status_code?

      if shared_cache ? res.cacheable_in_shared_cache? : res.cacheable?
        cache.store url, res
      else
        cache.delete url
      end

      res
    end

    def uri_for( path )
      path =~ /^https?:\/\// ? path : File.join( api_endpoint, path )
    end


  private

    def http_get( *args )
      http_request :get, *args
    end

    def http_request( method, url, header=default_header )
      http = Net::HTTP.new( url.host, url.port )

      http.read_timeout = read_timeout if read_timeout
      http.open_timeout = open_timeout if open_timeout

      logger.info('Request') { "#{method.upcase} #{url}" }
      logger.debug('Request') { header.to_hash }

      begin
        response = http.send method, url.request_uri, header.to_hash
      rescue *NET_HTTP_EXCEPTIONS => evar
        raise MetaKGS::Error::ConnectionFailed, evar
      rescue Timeout::Error => evar
        raise MetaKGS::Error::TimeoutError, evar
      end

      logger.info('Response') { response.code }
      logger.debug('Response') { response.to_hash }

      case response
      when Net::HTTPNotFound
        raise MetaKGS::Error::ResourceNotFound, response
      when Net::HTTPClientError, Net::HTTPServerError
        raise MetaKGS::Error::ClientError, response
      end

      response
    end

  end
end

