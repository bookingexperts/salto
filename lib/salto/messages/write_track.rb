module Salto
  module Messages
    class WriteTrack < Salto::Message
      def self.command_name
        'P'
      end

      def initialize(track:, text:, encoder:, eject_strategy: :retain)
        fields = Array.new(3)
        fields[0] = "#{self.class.command_name}#{track}"
        fields[1] = encoder
        fields[2] = Salto::Support::CardDetails::EJECT_STRATEGIES[eject_strategy] || eject_strategy
        fields[3] = Salto::Message.sanitize_text(text)
        super(fields)
      end
    end
  end
end
