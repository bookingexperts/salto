require 'minitest_helper'

module Salto
  module Audit
    class AuditRecordTest < Minitest::Spec
      it 'wraps a guest card audit message' do
        message = Salto::Message.new(['WF', 'Entrance', '01/10', '14:05', '0', 'I', '101'])
        record = Salto::Audit::AuditRecord.new(message)

        refute record.error?
        refute record.end_of_trail?
        assert_equal 'Entrance', record.door_identification
        assert_equal Time.parse("#{record.datetime.year}/10/01 14:05"), record.datetime
        assert_equal :open, record.incident
        assert_equal :in, record.direction
        assert_equal '101', record.card_identification
      end

      it 'wraps a staff card audit message' do
        message = Salto::Message.new(['WF', 'Entrance', '01/10', '14:05', '0', 'I', 'STAFF   ', '#0', 'Maintenance'])
        record = Salto::Audit::AuditRecord.new(message)

        refute record.error?
        refute record.end_of_trail?
        assert_equal 'Entrance', record.door_identification
        assert_equal Time.parse("#{record.datetime.year}/10/01 14:05"), record.datetime
        assert_equal :open, record.incident
        assert_equal :in, record.direction
        assert_equal 'STAFF', record.card_identification
        assert_equal '#0', record.copy_number
        assert_equal 'Maintenance', record.user
      end

      it 'sets the datetime to the passed year when a day-month combination is not for the current year' do
        future_date = Time.now + 86_400
        message = Salto::Message.new(['WF', 'Entrance', "#{future_date.day}/#{future_date.month}", '14:05', '0', 'I', 'STAFF   ', '#0', 'Maintenance'])
        record = Salto::Audit::AuditRecord.new(message)
        assert_equal Time.now.year - 1, record.datetime.year
      end

      it 'yields an incident' do
        record = Salto::Audit::AuditRecord.new(Salto::Message.new(['WF', 'Entrance', '01/10', '14:05', '2', 'I', '101']))
        assert_equal :invalid, record.incident

        record = Salto::Audit::AuditRecord.new(Salto::Message.new(['WF', 'Entrance', '01/10', '14:05', '3', 'I', '101']))
        assert_equal :access_denied, record.incident

        record = Salto::Audit::AuditRecord.new(Salto::Message.new(['WF', 'Entrance', '01/10', '14:05', '4', 'I', '101']))
        assert_equal :expired, record.incident

        record = Salto::Audit::AuditRecord.new(Salto::Message.new(['WF', 'Entrance', '01/10', '14:05', '5', 'I', '101']))
        assert_equal :anti_passback, record.incident
      end

      it 'yields the direction incident' do
        record = Salto::Audit::AuditRecord.new(Salto::Message.new(['WF', 'Entrance', '01/10', '14:05', '2', 'I', '101']))
        assert_equal :in, record.direction

        record = Salto::Audit::AuditRecord.new(Salto::Message.new(['WF', 'Entrance', '01/10', '14:05', '3', 'O', '101']))
        assert_equal :out, record.direction
      end

      it 'wraps an audit error message' do
        message = Salto::Message.new(['WE'])
        record = Salto::Audit::AuditRecord.new(message)

        assert record.error?
        refute record.end_of_trail?
      end

      it 'wraps an audit end of trail message' do
        message = Salto::Message.new(%w[WO Entrance])
        record = Salto::Audit::AuditRecord.new(message)

        refute record.error?
        assert record.end_of_trail?
      end
    end
  end
end
