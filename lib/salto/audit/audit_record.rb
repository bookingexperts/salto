module Salto
  module Audit
    class AuditRecord
      # Format: 'day/month' (default) or 'month/day', depending on the configuration of the interface
      DATETIME_FORMAT = '%d/%m %H:%M'.freeze

      attr_accessor :message

      def initialize(message)
        self.message = message
      end

      # General error: it is not possible to send the requested incidence. Possible causes could be:
      # - specified door or peripheral does not exist.
      # - database not accessible.
      # - etc.
      def error?
        message.fields[0] == 'WE'
      end

      # Overflow error: there is no more incidence to be sent. Depending on the command, the meaning of this error is as follows:
      # - 'WF': the audit trail of the specified door or peripheral is empty, i. e., no opening or rejection has been produced in the last days.
      # - 'WN': the last incidence in the audit trail has already be sent to the PMS, so no more incidence is available.
      # - 'WR': this case only occurs when the 'WR' command has been sent before any actual incidence collection request ('WF' or 'WN'): the interface cannot repeat anything since not previous request has been made.
      def end_of_trail?
        message.fields[0] == 'WO'
      end

      def door_identification
        message.fields[1]
      end

      def datetime
        @datetime ||=
          begin
            parsed_datetime = Time.strptime("#{message.fields[2]} #{message.fields[3]}", DATETIME_FORMAT)
            parsed_datetime = parsed_datetime.change(year: parsed_datetime.year - 1) if parsed_datetime > Time.now
            parsed_datetime
          end
      end

      def incident
        @incident ||=
          case message.fields[4].to_i
          when 0 then :open
          when 2 then :invalid
          when 3 then :access_denied
          when 4 then :expired
          when 5 then :anti_passback
          end
      end

      # - 'I': input or entrance reader.
      # - 'O': output or exit reader.
      def direction
        if message.fields[5] == 'I'
          :in
        else
          :out
        end
      end

      # The content of this field depends on the type of the card owner:
      # - Hotel guest: if the card corresponds to a hotel guest, this field will contain the name of the room to which the guest belongs.
      # - Staff: if the card corresponds to a staff user, this field will contain the word 'STAFF   ' (8 characters) and field #8 will contain the name of the user (see below).
      # - Special users: for other kind of users (such as spare card) this field is left empty (8 blank characters).
      def card_identification
        message.fields[6].strip
      end

      # - '#0': original card.
      # - '#1': first copy.
      # - '#2': second copy.
      # - '#D': indefinite copy (third or successive).
      # - '@1': single opening card number 1 (one-shot key).
      # - 'S1': spare card.
      # - 'S2': opening caused by means of a switch, button, keypad, etc.
      # - 'S3': opening caused online from the computer.
      def copy_number
        message.fields[7]
      end

      def user
        message.fields[8]
      end
    end
  end
end
