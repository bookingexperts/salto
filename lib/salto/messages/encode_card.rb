module Salto
  module Messages
    # Example: cn_message = Salto::Messages::EncodeCard.new(valid_from: Time.now, valid_till: 2.days.from_now, rooms: ['Room 1'], print_info: "John Doe\nAnonymousville", encoder: 'Online Encoder 1')
    class EncodeCard < Salto::Message
      SERIAL_NUMBER_RETURNS = {
        none: '0', # No serial number is returned
        last: '1', # Last written card serial number is returned
        all: '2'   # All written card serial numbers are returned
      }.freeze

      def self.command_name
        'CN'
      end

      def initialize(amount: nil, valid_from: nil, valid_till: nil, rooms: [], granted_authorizations: [], denied_authorizations: [], print_info: nil, operator: nil, encoder:, eject_strategy: :retain, serial_number_return: :all)
        fields = Array.new(15)
        fields[0] = "#{self.class.command_name}#{amount}"
        fields[1] = encoder
        fields[2] = Salto::Support::CardDetails::EJECT_STRATEGIES[eject_strategy] || eject_strategy

        rooms.to_a[0, 4].each_with_index { |room, index| fields[3 + index] = room[0, 24] }

        fields[7] = Salto::Support::CardDetails.encode_authorizations(granted_authorizations)
        fields[8] = Salto::Support::CardDetails.encode_authorizations(denied_authorizations)
        fields[9] = valid_from && valid_from.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        fields[10] = valid_till && valid_till.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        fields[11] = operator.to_s[0, 24]

        print_info.to_s.split("\n")[0, 3].each_with_index { |line, index| fields[12 + index] = Salto::Message.sanitize_text(line) } if print_info.present?
        fields[15] = SERIAL_NUMBER_RETURNS[serial_number_return] || serial_number_return

        super(fields)
      end
    end
  end
end
