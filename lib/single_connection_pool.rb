class SingleConnectionPool
  DEFAULTS = {}
  
  def initialize(options = {})
    @options = DEFAULTS.merge(options)
  end

  def with(options = {})
    options = @options.merge(options)
    host = options.fetch(:host)
    port = options.fetch(:port)
    socket = TCPSocket.open(host, port)
    yield socket
  ensure
    socket.close rescue nil
  end
end