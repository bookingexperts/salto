require 'minitest_helper'

module Salto
  module Audit
    class AuditTrailTest < Minitest::Spec
      let(:client) { Salto::Client.new('192.168.1.1:8090') }

      it 'fetches an audit trail for a door identification' do
        first_write_message = Salto::Message.encode('|WF|Entrance|')
        next_write_message = Salto::Message.encode('|WN|Entrance|')
        final_write_message = Salto::Message.encode('|WN|Entrance|')

        first_read_message = Salto::Message.new(['WF', 'Entrance', '01/10', '14:05', '0', 'I', '101'])
        next_read_message = Salto::Message.new(['WF', 'Entrance', '02/10', '11:05', '0', 'O', '101'])
        final_read_message = Salto::Message.new(%w[WO Entrance])

        mock = tcp_client_mock(
          write: [client.encode_message(first_write_message), client.encode_message(next_write_message), client.encode_message(final_write_message)],
          read: [
            Salto::Client::ACK,
            client.encode_message(first_read_message),
            Salto::Client::ACK,
            client.encode_message(next_read_message),
            Salto::Client::ACK,
            client.encode_message(final_read_message)
          ]
        )

        client.stub(:connection, mock) do
          trail = Salto::Audit::AuditTrail.fetch(client, door_identification: 'Entrance')
          assert_equal 2, trail.size
          assert_equal :in, trail[0].direction
          assert_equal :out, trail[1].direction
        end
      end

      it 'yields an error message when received' do
        write_message = Salto::Message.encode('|WF|Entrance|')
        error_message = Salto::Message.new(%w[WE Entrance])

        mock = tcp_client_mock(
          write: client.encode_message(write_message),
          read: [Salto::Client::ACK, client.encode_message(error_message)]
        )

        client.stub(:connection, mock) do
          trail = Salto::Audit::AuditTrail.fetch(client, door_identification: 'Entrance')
          assert_equal 1, trail.size
          assert trail[0].error?
        end
      end
    end
  end
end
