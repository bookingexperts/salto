require 'minitest_helper'

module Salto
  module Messages
    class ReadTrackTest < Minitest::Spec
      it 'builds a read track command' do
        message = Salto::Messages::ReadTrack.new(track: 1, encoder: 'Encoder 1', eject_strategy: :retain)
        assert_equal ['L1', 'Encoder 1', 'R'], message.fields

        message = Salto::Messages::ReadTrack.new(track: 2, encoder: 'Encoder 2', eject_strategy: :eject)
        assert_equal ['L2', 'Encoder 2', 'E'], message.fields
      end
    end
  end
end
