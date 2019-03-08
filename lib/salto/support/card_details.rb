module Salto
  module Support
    class CardDetails
      DATETIME_FORMAT = '%H%M%d%m%y'.freeze

      EJECT_STRATEGIES = {
        eject: 'E', # Ejection. The PC interface waits for the key to be removed from the encoder.
        retain: 'R', # Retention. The PC interface does not wait for the key to be removed.
        rear: 'T' # Ejection by the rear side (not used). Same effect as 'E'.
      }.freeze

      AUTHORIZATION_MAPPINGS = {
        1 => '1', 2 => '2', 3 => '3', 4 => '4', 5 => '5', 6 => '6', 7 => '7', 8 => '8',
        9 => '9', 10 => 'a', 11 => 'b', 12 => 'c', 13 => 'd', 14 => 'e', 15 => 'f',
        16 => 'g', 17 => 'h', 18 => 'i', 19 => 'j', 20 => 'k', 21 => 'l', 22 => 'm',
        23 => 'n', 24 => 'o', 25 => 'p', 26 => 'q', 27 => 'r', 28 => 's', 29 => 't',
        30 => 'u', 31 => 'v', 32 => 'w', 33 => 'x', 34 => 'y', 35 => 'z', 36 => '!',
        37 => '#', 38 => '$', 39 => '%', 40 => '&', 41 => '(', 42 => ')', 43 => '*',
        44 => '+', 45 => ',', 46 => '-', 47 => '.', 48 => '/', 49 => ':', 50 => ';',
        51 => '<', 52 => '=', 53 => '>', 54 => '?', 55 => '@', 56 => '[', 57 => '\\',
        58 => ']', 59 => '^', 60 => '_', 61 => '{', 62 => '}'
      }.freeze

      attr_accessor :message

      # Can be initialized as the result of a ReadCard (LT) message
      def initialize(message)
        self.message = message
      end

      def self.encode_authorizations(authorizations)
        authorizations.to_a.map { |auth| AUTHORIZATION_MAPPINGS[auth.to_i] }.join
      end

      def self.decode_authorizations(authorization_field)
        mappings = AUTHORIZATION_MAPPINGS.invert
        authorization_field.chars.map { |auth| mappings[auth] }.compact
      end

      def self.datetime(datetime_field)
        Time.strptime(datetime_field, DATETIME_FORMAT)
      end

      def encoder
        message.fields[1]
      end

      def card_type
        @card_type ||=
          case message.fields[2]
          when 'LM' then :staff_card
          when 'LR' then :spare_guest_card
          when 'LC' then :invalid_guest_card
          when 'LD' then :unidentified_card
          else :guest_card
          end
      end

      def guest_card?
        card_type == :guest_card
      end

      def rooms
        [message.fields[2], message.fields[3], message.fields[4], message.fields[5]].compact if guest_card?
      end

      def valid_for_main_room?
        message.fields[6] == 'CI' if guest_card?
        # Otherwise 'CO'
      end

      # '0' - original card.
      # '1' - first copy.
      # '2' - second copy.
      # 'I' - undefined copy (third and successive).
      # 'A' - one-shot key.
      def copy_number
        message.fields[7] if guest_card?
      end

      def granted_authorizations
        Salto::Support::CardDetails.decode_authorizations(message.fields[8]) if guest_card? && message.fields[8].present?
      end

      def valid_from
        Salto::Support::CardDetails.datetime(message.fields[9]) if guest_card? && message.fields[9].present?
      end

      def valid_till
        Salto::Support::CardDetails.datetime(message.fields[10]) if guest_card? && message.fields[10].present?
      end

      def operator
        message.fields[11] if guest_card?
      end
    end
  end
end
