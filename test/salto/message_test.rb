require 'minitest_helper'

module Salto
  class MessageTest < Minitest::Spec
    it 'initializes with an array of fields' do
      message = Salto::Message.new(['CN', 'Online Encoder 1', 'R', 'Room 1'])
      assert_equal ['CN', 'Online Encoder 1', 'R', 'Room 1'], message.fields
    end

    it 'encodes a message string' do
      message = Salto::Message.encode('|CN|Online Encoder 1|R|Room 1|')
      assert_equal ['CN', 'Online Encoder 1', 'R', 'Room 1'], message.fields
    end

    it 'decodes a raw message' do
      raw_message = Salto::Message.encode('|CN|Online Encoder 1|R|Room 1|').to_s
      message = Salto::Message.decode(raw_message)
      assert_equal ['CN', 'Online Encoder 1', 'R', 'Room 1'], message.fields
    end

    it 'transforms field delimiters to pipes when sanitizing strings' do
      text = Salto::Message.encode('|CN|Online Encoder 1|R|Room 1|').to_s
      assert_equal '|CN|Online Encoder 1|R|Room 1|', Salto::Message.sanitize_text(text)
    end

    it 'removes carriage returns when sanitizing strings' do
      assert_equal 'JOHN DOE|ANONYMOUSVILLE', Salto::Message.sanitize_text("JOHN DOE\r|ANONYMOUSVILLE\r")
    end

    it 'assumes command name to be in the first field' do
      message = Salto::Message.encode('|CN|Online Encoder 1|R|Room 1|')
      assert_equal 'CN', message.command
    end

    it 'does not have a command name when the message is an error' do
      message = Salto::Message.encode('|EG|')
      assert message.error?
      assert_nil message.command
    end

    it 'returns the command details' do
      message = Salto::Message.encode('|CN|Online Encoder 1|R|Room 1|')
      assert_equal ['Online Encoder 1', 'R', 'Room 1'], message.details
    end

    it 'returns the given error message when passed' do
      message = Salto::Message.encode('|EG|It is broken|')
      assert message.error?
      assert_equal 'It is broken', message.error
    end

    it 'returns the default error message when no error message is specified for a general error' do
      message = Salto::Message.encode('|EG||')
      assert message.error?
      assert_equal 'General error', message.error
    end

    it 'translates error messages' do
      message = Salto::Message.encode('|EF|')
      assert message.error?
      assert_equal 'Format error. The card has been encoded by another system or may be damaged.', message.error
      I18n.with_locale(:nl) { assert_equal 'Ongeldig format. De kaart is door een ander systeem geschreven of is beschadigd.', message.error }
    end
  end
end
