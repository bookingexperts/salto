require 'minitest/autorun'
require 'salto'

def tcp_client_mock(write:, read:)
  tcp_client_mock = Minitest::Mock.new

  [write].flatten.each do |message|
    tcp_client_mock.expect(:write, true, [message.dup])
  end

  [read].flatten.each do |message|
    message.chars.each do |char|
      tcp_client_mock.expect(:read, char, [1])
    end
  end

  tcp_client_mock.expect(:close, true)
end
