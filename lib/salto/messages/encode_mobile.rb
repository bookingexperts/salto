module Salto
  module Messages
    class EncodeMobile < Salto::Messages::EncodeCard
      def self.command_name
        'CNM'
      end

      def initialize(phone_number:, text_message:, **args)
        super(encoder: phone_number, **args)
        fields.delete_at(2) # Delete eject strategy
        fields[14] = text_message.to_s[0, 256]
      end
    end
  end
end
