require 'minitest_helper'

module Salto
  module Support
    class BinaryMobileKeyTest < Minitest::Spec
      it 'wraps a binary mobile key message without an installation ID' do
        message = Salto::Message.new(['CNMB', '+34619123456', '11A5C9DF012C4A8061FEACCDE8'])
        binary_mobile_key = Salto::Support::BinaryMobileKey.new(message)

        assert_equal '11A5C9DF012C4A8061FEACCDE8', binary_mobile_key.key
        assert_nil binary_mobile_key.installation_id
      end

      it 'wraps a binary mobile key message with an installation ID' do
        message = Salto::Message.new(['CNMB', '+34619123456', '11A5C9DF012C4A8061FEACCDE8', 'tDexFrFquvhyA7'])
        binary_mobile_key = Salto::Support::BinaryMobileKey.new(message)

        assert_equal '11A5C9DF012C4A8061FEACCDE8', binary_mobile_key.key
        assert_equal 'tDexFrFquvhyA7', binary_mobile_key.installation_id
      end
    end
  end
end
