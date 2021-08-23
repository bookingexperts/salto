require 'minitest_helper'

module Salto
  module Messages
    class CopyMobileBinaryTest < Minitest::Spec
      it 'builds a copy mobile binary command that returns an installation ID' do
        now = Time.now

        message =
          Salto::Messages::CopyMobileBinary.new(
            phone_number: '0612345678',
            valid_from: now,
            valid_till: now + (3600 * 24),
            rooms: ['Room 1', 'Room 2', 'Room 3', 'Room 4'],
            granted_authorizations: [1, 2, 3, 4, 5],
            denied_authorizations: [62, 61, 60, 59, 58],
            operator: 'Operator',
            return_installation_id: true
          )

        valid_from = now.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        valid_till = (now + (3600 * 24)).strftime(Salto::Support::CardDetails::DATETIME_FORMAT)

        assert_equal ['CCMB', '0612345678', 'Room 1', 'Room 2', 'Room 3', 'Room 4', '12345', '}{_^]', valid_from, valid_till, 'Operator', nil, nil, nil, '1'], message.fields
      end

      it 'builds a copy mobile binary command that does not return an installation ID' do
        now = Time.now

        message =
          Salto::Messages::CopyMobileBinary.new(
            phone_number: '0612345678',
            valid_from: now,
            valid_till: now + (3600 * 24),
            rooms: ['Room 1', 'Room 2', 'Room 3', 'Room 4'],
            granted_authorizations: [1, 2, 3, 4, 5],
            denied_authorizations: [62, 61, 60, 59, 58],
            operator: 'Operator',
            return_installation_id: false
          )

        valid_from = now.strftime(Salto::Support::CardDetails::DATETIME_FORMAT)
        valid_till = (now + (3600 * 24)).strftime(Salto::Support::CardDetails::DATETIME_FORMAT)

        assert_equal ['CCMB', '0612345678', 'Room 1', 'Room 2', 'Room 3', 'Room 4', '12345', '}{_^]', valid_from, valid_till, 'Operator', nil, nil, nil, '0'], message.fields
      end
    end
  end
end
