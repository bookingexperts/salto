require 'minitest_helper'

module Salto
  module Messages
    class CheckoutTest < Minitest::Spec
      it 'builds a checkout command' do
        message = Salto::Messages::Checkout.new(room: 'Room 1')
        assert_equal ['CO', '0', 'Room 1'], message.fields
      end
    end
  end
end
