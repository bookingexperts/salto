module Salto
  module Messages
    # Example: l1_message = Salto::Messages::ReadTrack.new(track: 1, encoder: 'Online Encoder 1')
    class ReadTrack < Salto::Message
      def self.command_name
        'L'
      end

      def initialize(track:, encoder:, eject_strategy: :retain)
        fields = Array.new(3)
        fields[0] = "#{self.class.command_name}#{track}"
        fields[1] = encoder
        fields[2] = Salto::Support::CardDetails::EJECT_STRATEGIES[eject_strategy] || eject_strategy
        super(fields)
      end
    end
  end
end
