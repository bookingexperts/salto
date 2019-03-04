require 'minitest_helper'

module Salto
  module Messages
    class EncodeMobileTest < Minitest::Spec
      it 'builds an encode mobile command' do
        now = Time.now

        message =
          Salto::Messages::EncodeMobile.new(
            phone_number: '0612345678',
            text_message: "John Doe\nAnonymousVille\nGuest",
            valid_from: now,
            valid_till: now + (3600 * 24),
            rooms: ['Room 1', 'Room 2', 'Room 3', 'Room 4'],
            granted_authorizations: [1, 2, 3, 4, 5],
            denied_authorizations: [62, 61, 60, 59, 58],
            operator: 'Operator',
            serial_number_return: :all
          )

        valid_from = now.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        valid_till = (now + (3600 * 24)).strftime(Salto::Support::CardDetails::DATETIME_FORMAT)

        assert_equal ['CNM', '0612345678', 'Room 1', 'Room 2', 'Room 3', 'Room 4', '12345', '}{_^]', valid_from, valid_till, 'Operator', nil, nil, nil, "John Doe\nAnonymousVille\nGuest"], message.fields
      end
    end
  end
end
