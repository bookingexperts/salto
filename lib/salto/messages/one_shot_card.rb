module Salto
  module Messages
    class OneShotCard < Salto::Messages::EncodeCard
      def self.command_name
        'CA'
      end
    end
  end
end
