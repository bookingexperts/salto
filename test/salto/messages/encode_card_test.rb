require 'minitest_helper'

module Salto
  module Support
    class CardDetailsTest < Minitest::Spec
      it 'builds an encode card command' do
        now = Time.now

        message =
          Salto::Messages::EncodeCard.new(
            valid_from: now,
            valid_till: now + (3600 * 24),
            rooms: ['Room 1', 'Room 2', 'Room 3', 'Room 4'],
            granted_authorizations: [1, 2, 3, 4, 5],
            denied_authorizations: [62, 61, 60, 59, 58],
            print_info: "John Doé\nAnonymousVille\nGuest",
            operator: 'Operator',
            encoder: 'Encoder 1',
            eject_strategy: :retain,
            serial_number_return: :all
          )

        valid_from = now.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        valid_till = (now + (3600 * 24)).strftime(Salto::Support::CardDetails::DATETIME_FORMAT)

        assert_equal ['CN', 'Encoder 1', 'R', 'Room 1', 'Room 2', 'Room 3', 'Room 4', '12345', '}{_^]', valid_from, valid_till, 'Operator', 'John Doe', 'AnonymousVille', 'Guest', '2'], message.fields
      end

      it 'allows different eject strategies' do
        assert_equal 'E', Salto::Messages::EncodeCard.new(encoder: '1', eject_strategy: :eject).fields[2]
        assert_equal 'R', Salto::Messages::EncodeCard.new(encoder: '1', eject_strategy: :retain).fields[2]
        assert_equal 'T', Salto::Messages::EncodeCard.new(encoder: '1', eject_strategy: :rear).fields[2]
      end

      it 'allows diffeent serial number returns' do
        assert_equal '0', Salto::Messages::EncodeCard.new(encoder: '1', serial_number_return: :none).fields[15]
        assert_equal '1', Salto::Messages::EncodeCard.new(encoder: '1', serial_number_return: :last).fields[15]
        assert_equal '2', Salto::Messages::EncodeCard.new(encoder: '1', serial_number_return: :all).fields[15]
      end

      it 'allows different amounts' do
        assert_equal 'CN', Salto::Messages::EncodeCard.new(encoder: '1', amount: nil).fields[0]
        assert_equal 'CN1', Salto::Messages::EncodeCard.new(encoder: '1', amount: 1).fields[0]
        assert_equal 'CN2', Salto::Messages::EncodeCard.new(encoder: '1', amount: 2).fields[0]
      end
    end
  end
end
