module Salto
  class Message
    FIELD_DELIMITER = String.new("\xB3", encoding: Salto::Client::ENCODING).freeze # Each field in a message is delimited by this separator character
    ERRORS = %w[ES NC NF OV EP EF TD ED EA OS EO EV EG].freeze # Error message keys

    attr_reader :fields

    def initialize(fields = nil)
      @fields = fields.to_a
    end

    # Example: Salto::Message.encode('|CN|Online Encoder 1|R|Room 1|')
    def self.encode(message_string)
      new(message_string.split('|', -1)[1..-2].map(&:presence))
    end

    def self.decode(raw_message)
      new(raw_message.split(FIELD_DELIMITER)[1..-1].map(&:presence))
    end

    def self.sanitize_text(text)
      ActiveSupport::Inflector.transliterate(text.force_encoding('utf-8'), '').encode(Salto::Client::ENCODING, invalid: :replace, undef: :replace, replace: '').delete("\r")
    end

    def command
      fields.first unless error?
    end

    def details
      fields[1..-1]
    end

    def error?
      ERRORS.include?(fields.first)
    end

    def error
      return unless error?

      if fields.first == 'EG'
        # Yields an encoder or phone number, followed by an error message
        fields.last.presence || I18n.t('EG', scope: 'salto.errors')
      else
        I18n.t(fields.first, scope: 'salto.errors')
      end
    end

    def to_s
      String.new(FIELD_DELIMITER + fields.join(FIELD_DELIMITER) + FIELD_DELIMITER, encoding: Salto::Client::ENCODING)
    end
  end
end
