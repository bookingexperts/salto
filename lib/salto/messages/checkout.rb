module Salto
  module Messages
    # Example: mc_message = Salto::Messages::Checkout.new(room: 'Room 1')
    class Checkout < Salto::Message
      def self.command_name
        'CO'
      end

      def initialize(room:)
        fields = Array.new(3)
        fields[0] = self.class.command_name
        fields[1] = '0'
        fields[2] = room
        super(fields)
      end
    end
  end
end
