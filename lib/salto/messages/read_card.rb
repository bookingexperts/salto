module Salto
  module Messages
    # Example: lt_message = Salto::Messages::ReadCard.new(encoder: 'Online Encoder 1')
    class ReadCard < Salto::Message
      def self.command_name
        'LT'
      end

      def initialize(encoder:, eject_strategy: :retain)
        fields = Array.new(3)
        fields[0] = self.class.command_name
        fields[1] = encoder
        fields[2] = Salto::Support::CardDetails::EJECT_STRATEGIES[eject_strategy] || eject_strategy
        super(fields)
      end
    end
  end
end
