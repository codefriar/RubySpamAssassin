class RubySpamAssassin::SpamClient
  require 'socket'
  require 'timeout'

  def initialize(host="localhost", port=783, timeout=5)
    @port = port
    @host = host
    @timeout =timeout
    @socket = TCPSocket.open(@host, @port)
  end

  def reconnect
    @socket = @socket || TCPSocket.open(@host, @port)
  end

  def send_symbol(message)
    protocol_response = send_message("SYMBOLS", message)
    result = process_headers protocol_response[0...2]
    result.tags = protocol_response[3...-1].join(" ").split(',')
  end

  def check(message)
    protocol_response = send_message("CHECK", message)
    result = process_headers protocol_response[0...2]
  end

  def report(message)
    protocol_response = send_message("REPORT", message)
    result = process_headers protocol_response[0...2]
    result.report = protocol_response[3..-1].join
    result.rules = RubySpamAssassin::ReportParser.parse(result.report)
    result
  end

  def report_ifspam(message)
    result = report(message).spam?
  end

  def skip
    protocol_response = send_message("SKIP", message)
  end

  def ping
    protocol_response = send_message("PING", message)
    result = process_headers protocol_response[0]
  end

  alias :process :report

  private
  def send_message(command, message)
    length = message.length
    @socket.write(command + " SPAMC/1.2\r\n")
    @socket.write("Content-length: " + length.to_s + "\r\n\r\n")
    @socket.write(message)
    @socket.shutdown(1) #have to shutdown sending side to get response
    response = @socket.readlines
    @socket.close #might as well close it now

    response
  end

  def process_headers(headers)
    result = RubySpamAssassin::SpamResult.new
    headers.each do |line|
      case line.chomp
        when /(.+)\/(.+) (.+) (.+)/ then
          result.response_version = $2
          result.response_code = $3
          result.response_message = $4
        when /^Spam: (.+) ; (.+) . (.+)$/ then
          result.score = $2
          result.spam = $1
          result.threshold = $3
        when /Content-length: (.+)/ then
          result.content_length = $1
      end
    end
    result
  end
end