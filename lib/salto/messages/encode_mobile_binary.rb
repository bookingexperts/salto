module Salto
  module Messages
    class EncodeMobileBinary < Salto::Messages::EncodeCard
      def self.command_name
        'CNMB'
      end

      def initialize(phone_number: nil, return_installation_id: true, **args)
        super(encoder: phone_number, **args)
        fields.delete_at(2) # Delete eject strategy
        fields[14] = (return_installation_id ? '1' : '0')
      end
    end
  end
end
