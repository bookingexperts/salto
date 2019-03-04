require 'minitest_helper'

module Salto
  module Messages
    class CopyCardTest < Minitest::Spec
      it 'builds a copy card command' do
        now = Time.now

        message =
          Salto::Messages::CopyCard.new(
            valid_from: now,
            valid_till: now + (3600 * 24),
            rooms: ['Room 1', 'Room 2', 'Room 3', 'Room 4'],
            granted_authorizations: [1, 2, 3, 4, 5],
            denied_authorizations: [62, 61, 60, 59, 58],
            print_info: "John Doe\nAnonymousVille\nGuest",
            operator: 'Operator',
            encoder: 'Encoder 1',
            eject_strategy: :retain,
            serial_number_return: :all
          )

        valid_from = now.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        valid_till = (now + (3600 * 24)).strftime(Salto::Support::CardDetails::DATETIME_FORMAT)

        assert_equal ['CC', 'Encoder 1', 'R', 'Room 1', 'Room 2', 'Room 3', 'Room 4', '12345', '}{_^]', valid_from, valid_till, 'Operator', 'John Doe', 'AnonymousVille', 'Guest', '2'], message.fields
      end
    end
  end
end
