module Salto
  module Messages
    class CopyMobile < Salto::Messages::EncodeMobile
      def self.command_name
        'CCM'
      end
    end
  end
end
