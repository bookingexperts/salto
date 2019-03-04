require 'minitest_helper'

module Salto
  module Messages
    class OneShotCardTest < Minitest::Spec
      it 'builds a one shot card command' do
        message =
          Salto::Messages::OneShotCard.new(
            rooms: ['Room 1', 'Room 2', 'Room 3', 'Room 4'],
            granted_authorizations: [1, 2, 3, 4, 5],
            denied_authorizations: [62, 61, 60, 59, 58],
            print_info: "John Doe\nAnonymousVille\nGuest",
            operator: 'Operator',
            encoder: 'Encoder 1',
            eject_strategy: :retain,
            serial_number_return: :all
          )

        assert_equal ['CA', 'Encoder 1', 'R', 'Room 1', 'Room 2', 'Room 3', 'Room 4', '12345', '}{_^]', nil, nil, 'Operator', 'John Doe', 'AnonymousVille', 'Guest', '2'], message.fields
      end
    end
  end
end
