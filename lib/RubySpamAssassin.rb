module RubySpamAssassin
  class SpamResult

    attr_accessor :response_version,
                  :response_code,
                  :response_message,
                  :spam,
                  :score,
                  :threshold,
                  :tags,
                  :report,
                  :content_length

    #returns true if the message was spam, otherwise false
    def spam?
      (@spam == "True" || @spam == "Yes") ? True : False
    end
  end

  class SpamClient

    require 'socket'
    require 'timeout'
#    require 'spam_result'

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
      result = process_headers(SpamResult.new, protocol_response[0...2])
      result.tags = protocol_response[3...-1].join(" ").split(',')
    end

    def check(message)
      protocol_response = send_message("CHECK", message)
      result = process_headers(SpamResult.new, protocol_response[0...2])
    end

    def report(message)
      protocol_response = send_message("REPORT", message)
      result = process_headers(SpamResult.new, protocol_response[0...2])
      result.report = protocol_response[3..-1].join
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
      result = process_headers(SpamResult.new, protocol_response[0])
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

    def process_headers(result, headers)
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
end
