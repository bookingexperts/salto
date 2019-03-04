require 'minitest_helper'

module Salto
  module Messages
    class ReadTrackTest < Minitest::Spec
      it 'builds a write track command' do
        message = Salto::Messages::WriteTrack.new(track: 1, text: 'Track1', encoder: 'Encoder 1', eject_strategy: :retain)
        assert_equal ['P1', 'Encoder 1', 'R', 'Track1'], message.fields

        message = Salto::Messages::WriteTrack.new(track: 2, text: 'Track2', encoder: 'Encoder 2', eject_strategy: :eject)
        assert_equal ['P2', 'Encoder 2', 'E', 'Track2'], message.fields
      end
    end
  end
end
