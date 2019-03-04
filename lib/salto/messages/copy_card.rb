module Salto
  module Messages
    class CopyCard < Salto::Messages::EncodeCard
      def self.command_name
        'CC'
      end
    end
  end
end
