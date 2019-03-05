require 'i18n'
require 'time'

require 'active_support'
require 'active_support/core_ext/object/blank'

require 'tcp-client'

require 'salto/client'
require 'salto/message'
require 'salto/response'

require 'salto/audit/audit_record'
require 'salto/audit/audit_trail'

require 'salto/messages/encode_card'
require 'salto/messages/encode_mobile'
require 'salto/messages/copy_card'
require 'salto/messages/copy_mobile'
require 'salto/messages/one_shot_card'
require 'salto/messages/read_card'
require 'salto/messages/read_track'
require 'salto/messages/write_track'

require 'salto/support/card_details'

require 'salto/version'

module Salto
  I18n.load_path += Dir[File.expand_path('../config/locales', __dir__) + '/*.yml']
end
