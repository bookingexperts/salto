require 'minitest_helper'

module Salto
  class ClientTest < Minitest::Spec
    let(:client) { Salto::Client.new('192.168.1.1:8090') }

    it 'queries whether the client is ready' do
      client.stub(:connection, tcp_client_mock(write: Salto::Client::ENQ, read: Salto::Client::ACK)) do
        assert client.ready?
      end

      client.stub(:connection, tcp_client_mock(write: Salto::Client::ENQ, read: Salto::Client::NAK)) do
        refute client.ready?
      end
    end

    it 'sends a message' do
      write_message = Salto::Message.encode('|CN|Online Encoder 1|R|Room 1|')
      read_message = Salto::Message.encode('|CN|Online Encoder 1|')

      mock = tcp_client_mock(
        write: client.encode_message(write_message),
        read: [
          Salto::Client::ACK,
          client.encode_message(read_message)
        ]
      )

      client.stub(:connection, mock) do
        assert_equal ['CN', 'Online Encoder 1'], client.send_message(write_message).message.fields
      end
    end

    it 'awaits ready state and retries three times when a NAK is received' do
      write_message = Salto::Message.encode('|CN|Online Encoder 1|R|Room 1|')

      mock = tcp_client_mock(
        write: [client.encode_message(write_message), Salto::Client::ENQ] * 3,
        read: [Salto::Client::NAK, Salto::Client::ACK] * 6
      )

      client.stub(:connection, mock) do
        assert client.send_message(write_message).nak?
      end
    end

    it 'raises an error when an invalid acknowledgement is returned' do
      client.stub(:connection, tcp_client_mock(write: Salto::Client::ENQ, read: 'F')) do
        assert_raises(Salto::Client::InvalidAcknowledgement) { client.ready? }
      end
    end

    it 'encodes messages with LRC skip when enabled' do
      client.lrc_skip = true
      message = Salto::Message.encode('|CN|Online Encoder 1|R|Room 1|')
      assert_equal client.encode_message(message).chars.last, Salto::Client::LRC_SKIP
    end

    it 'writes debug to a logger when set' do
      client.logger = Minitest::Mock.new
      client.logger.expect(:debug, true, ['[SALTO][192.168.1.1:8090] -> ENQ'])
      client.logger.expect(:debug, true, ['[SALTO][192.168.1.1:8090] <- ACK'])

      client.stub(:connection, tcp_client_mock(write: Salto::Client::ENQ, read: Salto::Client::ACK)) do
        assert client.ready?
      end
    end
  end
end
