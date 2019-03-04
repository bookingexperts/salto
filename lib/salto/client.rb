module Salto
  class Client
    ENCODING = 'ASCII-8BIT'.freeze
    MAX_RETRIES = 3

    STX = "\x02".freeze # Start of text, indicates the start of a message.
    ETX = "\x03".freeze # End of text, indicates the end of a message
    ENQ = "\x05".freeze # Enquiry about the PC interface being ready to receive a new message.
    ACK = "\x06".freeze # Positive acknowledgement to a PMS message or enquiry (ENQ).
    NAK = "\x15".freeze # Negative acknowledgement to a PMS message or enquiry (ENQ).

    LRC_SKIP = "\x0D".freeze # The PMS can avoid LRC calculation by sending a 0DH value (return character)
    LRC_MESSAGE_TEMPLATE = "%<message>s#{ETX}".freeze # LRC message must not include STX and should include ETX
    MESSAGE_TEMPLATE = "#{STX}%<message>s#{ETX}%<lrc>s".freeze

    class InvalidAcknowledgement < StandardError; end

    attr_accessor :endpoint, :logger, :lrc_skip

    # client = Salto::Client.new('192.168.1.120:8090')
    def initialize(endpoint, logger: nil, lrc_skip: false)
      self.endpoint = endpoint
      self.logger = logger
      self.lrc_skip = lrc_skip
    end

    def self.lrc(message)
      lrc = 0
      format(LRC_MESSAGE_TEMPLATE, message: message).each_byte { |b| lrc = lrc ^ b }
      lrc.chr
    end

    def ready?
      send_request(ENQ).ack?
    end

    def connection
      TCPClient.new.connect(endpoint, configuration)
    end

    def send_request(request)
      tcp_connection = connection
      _send_request(tcp_connection, request)
    ensure
      tcp_connection.close
    end

    def send_message(message)
      send_request(encode_message(message))
    end

    def encode_message(message)
      lrc = lrc_skip ? LRC_SKIP : Salto::Client.lrc(message)
      format(MESSAGE_TEMPLATE, message: message, lrc: lrc)
    end

    def configuration
      @configuration ||=
        TCPClient::Configuration.create do |config|
          config.connect_timeout = 10 # seconds to connect the server
          config.write_timeout = 10 # seconds to write a request
          config.read_timeout = 30 # seconds to read some bytes. Must including waiting time to place the card
        end
    end

    def _send_request(tcp_client, request, try: 1)
      debug(:out, request)
      tcp_client.write(request)

      acknowledgement = tcp_client.read(1)
      debug(:in, acknowledgement)

      if request == ENQ && [ACK, NAK].include?(acknowledgement)
        Salto::Response.new(acknowledgement)
      elsif acknowledgement == ACK
        read_stx(tcp_client)
      elsif acknowledgement == NAK
        if try < MAX_RETRIES
          await_ready(tcp_client)
          _send_request(tcp_client, request, try: try + 1)
        else
          Salto::Response.new(acknowledgement)
        end
      else
        raise(InvalidAcknowledgement, "Invalid SALTO acknowledgement: #{acknowledgement}")
      end
    end

    private

    def read_stx(tcp_client)
      response = StringIO.new
      current_control_char = tcp_client.read(1)
      response << current_control_char

      # Read until ETX
      while current_control_char != ETX
        current_control_char = tcp_client.read(1)
        response << current_control_char
      end

      # Read the LCR char
      response << tcp_client.read(1)

      raw_response = response.string
      debug(:in, raw_response)

      Salto::Response.new(raw_response)
    end

    def await_ready(tcp_client)
      try = 1
      loop do
        debug(:out, ' ENQ ')
        tcp_client.write(ENQ)
        acknowledgement = tcp_client.read(1)
        debug(:in, acknowledgement)

        break if acknowledgement == ACK || try >= MAX_RETRIES

        try += 1
        sleep(0.2)
      end
    end

    def debug(direction, message)
      return unless logger

      message = message.dup.force_encoding(ENCODING)
      message.gsub!(STX, 'STX ')
      message.gsub!(ETX, ' ETX')
      message.gsub!(ENQ, 'ENQ')
      message.gsub!(ACK, 'ACK')
      message.gsub!(NAK, 'NAK')
      message.gsub!(LRC_SKIP, 'LRC_SKIP')
      message.gsub!(Salto::Message::FIELD_DELIMITER, '|')

      logger.debug("[SALTO][#{endpoint}] #{direction == :out ? '->' : '<-'} #{message}")
    end
  end
end
