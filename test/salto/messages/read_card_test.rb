require 'minitest_helper'

module Salto
  module Messages
    class ReadCardTest < Minitest::Spec
      it 'builds a read card command' do
        message = Salto::Messages::ReadCard.new(encoder: 'Encoder 1', eject_strategy: :retain)
        assert_equal ['LT', 'Encoder 1', 'R'], message.fields
      end
    end
  end
end
