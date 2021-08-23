module Salto
  module Messages
    class CopyMobileBinary < Salto::Messages::EncodeMobileBinary
      def self.command_name
        'CCMB'
      end
    end
  end
end
