module Salto
  class Response
    class InvalidMessage < StandardError; end

    ACK = "\x06".freeze # Positive acknowledgement to a PMS message or enquiry (ENQ).
    NAK = "\x15".freeze # Negative acknowledgement to a PMS message or enquiry (ENQ).

    attr_reader :raw_response

    def initialize(raw_response)
      @raw_response = raw_response.force_encoding(Salto::Client::ENCODING)
      verify! if message?
    end

    def ack?
      raw_response == ACK
    end

    def nak?
      raw_response == NAK
    end

    def message?
      raw_response[0] == Salto::Client::STX
    end

    def verify!
      raise(InvalidMessage, 'LRC is incorrect!') if lrc != Salto::Client::LRC_SKIP && Salto::Client.lrc(raw_message) != lrc

      true
    end

    def lrc
      @lrc ||= raw_response[/\A#{Salto::Client::STX}.+?#{Salto::Client::ETX}(.+?)\z/, 1]
    end

    def raw_message
      @raw_message ||= raw_response[/\A#{Salto::Client::STX}(.+?)#{Salto::Client::ETX}/, 1]
    end

    def message
      Salto::Message.decode(raw_message).freeze
    end
  end
end
