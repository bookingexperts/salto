require 'minitest_helper'

module Salto
  class ResponseTest < Minitest::Spec
    let(:client) { Salto::Client.new('192.168.1.1:8090') }
    let(:stx) { client.encode_message(Salto::Message.encode('|CN|Online Encoder 1|').to_s) }

    it 'sets the response message' do
      response = Salto::Response.new(stx)

      refute_nil response.raw_response
      assert response.message?
      assert response.message
    end

    it 'raises an error when a raw message has en invalid LRC' do
      chars = stx.chars
      chars[chars.size - 1] = 'F'

      assert_raises(Salto::Response::InvalidMessage) { Salto::Response.new(chars.join) }
    end

    it 'wraps an ack' do
      Salto::Response.new(Salto::Client::ACK.dup).ack?
    end

    it 'wraps a nak' do
      Salto::Response.new(Salto::Client::NAK.dup).nak?
    end

    it 'yields the raw message data' do
      response = Salto::Response.new(stx)
      assert_equal Salto::Message.encode('|CN|Online Encoder 1|').to_s, response.raw_message
    end
  end
end
