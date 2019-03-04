require 'minitest_helper'

module Salto
  module Support
    class CardDetailsTest < Minitest::Spec
      it 'wraps a card message' do
        now = Time.now
        valid_from = now.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        valid_till = (now + (3600 * 24)).strftime(Salto::Support::CardDetails::DATETIME_FORMAT)

        message = Salto::Message.new(['LT', 'Encoder 1', 'Room 1', 'Room 2', 'Room 3', 'Room 4', 'CI', '0', '12345', valid_from, valid_till, 'Operator'])
        card = Salto::Support::CardDetails.new(message)

        assert_equal 'Encoder 1', card.encoder
        assert_equal :guest_card, card.card_type
        assert card.guest_card?
        assert_equal ['Room 1', 'Room 2', 'Room 3', 'Room 4'], card.rooms
        assert card.valid_for_main_room?
        assert_equal '0', card.copy_number
        assert_equal (1..5).to_a, card.granted_authorizations
        assert_equal valid_from, card.valid_from.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        assert_equal valid_till, card.valid_till.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        assert_equal 'Operator', card.operator
      end

      it 'is invalid when checked out' do
        message = Salto::Message.new(['LT', 'Encoder 1', 'Room 1', nil, nil, nil, 'CO', '0', nil, nil, nil, nil])
        card = Salto::Support::CardDetails.new(message)
        refute card.valid_for_main_room?
      end

      it 'takes other card types into account' do
        card = Salto::Support::CardDetails.new(Salto::Message.new(['LT', 'Encoder 1', 'LM']))
        assert_equal :staff_card, card.card_type

        card = Salto::Support::CardDetails.new(Salto::Message.new(['LT', 'Encoder 1', 'LR']))
        assert_equal :spare_guest_card, card.card_type

        card = Salto::Support::CardDetails.new(Salto::Message.new(['LT', 'Encoder 1', 'LC']))
        assert_equal :invalid_guest_card, card.card_type

        card = Salto::Support::CardDetails.new(Salto::Message.new(['LT', 'Encoder 1', 'LD']))
        assert_equal :unidentified_card, card.card_type
      end

      it 'returns nil for attributes that dont apply for non guest cards' do
        card = Salto::Support::CardDetails.new(Salto::Message.new(['LT', 'Encoder 1', 'LM']))
        assert_equal :staff_card, card.card_type

        assert_equal 'Encoder 1', card.encoder
        refute card.guest_card?
        assert_nil card.rooms
        assert_nil card.valid_for_main_room?
        assert_nil card.copy_number
        assert_nil card.granted_authorizations
        assert_nil card.valid_from
        assert_nil card.valid_till
        assert_nil card.operator
      end
    end
  end
end
