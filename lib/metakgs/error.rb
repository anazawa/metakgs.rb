module MetaKGS
  class Error < StandardError
    class ClientError      < Error;       end
    class ConnectionFailed < ClientError; end
    class TimeoutError     < ClientError; end
    class ResourceNotFound < ClientError; end
  end
end

