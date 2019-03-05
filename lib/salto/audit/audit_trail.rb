module Salto
  module Audit
    class AuditTrail
      # Fetches the audit trail for a given door. Audit retention is based on configuration in Salto.
      def self.fetch(client, door_identification:)
        audit_records = []
        end_of_trail = false

        tcp_connection = client.connection
        next_message = Salto::Message.new(['WF', door_identification])

        until end_of_trail
          response = client._send_request(tcp_connection, client.encode_message(next_message))

          audit_record = Salto::Audit::AuditRecord.new(response.message)
          audit_records << audit_record unless audit_record.end_of_trail?

          next_message = Salto::Message.new(['WN', door_identification])
          end_of_trail = audit_record.error? || audit_record.end_of_trail?
        end

        audit_records
      ensure
        tcp_connection&.close
      end
    end
  end
end
