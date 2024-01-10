require "hubbado/upsert_version/version"
require 'active_record'
require 'configure'
require 'mimic'

module Hubbado
  class UpsertVersion
    include Configure

    configure :upsert_version

    attr_reader :klass, :target

    Error = Class.new(StandardError)

    Unchanged = Data.define { def upserted? = false }
    Upserted = Data.define(:attributes) { def upserted? = true }

    def self.build(klass, target: nil)
      new(klass, target: target)
    end

    def initialize(klass, target: nil)
      target ||= klass.primary_key

      @klass = klass
      @target = Array.wrap(target).map(&:to_sym)
    end

    def call(attributes)
      encrypted = encrypted_attributes(attributes)
      casted = encrypted.to_h do |key, value|
        [key.to_sym, table[key].type_cast_for_database(value)]
      end

      if casted.values_at(*target, :version).any?(&:blank?)
        raise Error,
          "Both target (#{target.join ', '}) and version values are required for upsert_version"
      end

      now = DateTime.now.utc
      if has_column?(:created_at)
        casted[:created_at] ||= table[:created_at].type_cast_for_database(now)
      end
      if has_column?(:updated_at)
        casted[:updated_at] ||= table[:updated_at].type_cast_for_database(now)
      end
      if klass.inheritance_column && has_column?(klass.inheritance_column)
        casted[klass.inheritance_column] ||= klass.sti_name
      end

      insert = upsert_insert(casted)
      update = upsert_update(casted)

      result = ActiveRecord::Base.connection.execute(
        "#{insert} ON CONFLICT (#{target.join(', ')}) DO #{update} RETURNING *"
      )
      attributes = result.to_a.first

      if attributes
        Upserted.new(attributes)
      else
        Unchanged.new
      end
    end

    module Substitute
      include RecordInvocation

      record def call(attributes)
        @result
      end

      def set_result(result)
        @result = result
      end

      def called?
        invoked?(:call)
      end

      def called_with?(attributes)
        invoked?(:call, attributes: attributes)
      end
    end

    private

    def encrypted_attributes(attributes)
      return attributes unless klass_lockbox_attributes
      attributes_for_encryption = attributes.slice(*klass_lockbox_attributes)

      encrypted_record = klass.new(attributes_for_encryption)
      encrypted_attributes = attributes_for_encryption.keys.map do |key|
        {
          "#{key}_ciphertext" => encrypted_record.send("#{key}_ciphertext")
        }
      end.reduce(:merge) || {}

      attributes.except(*attributes_for_encryption.keys).merge(encrypted_attributes)
    end

    def klass_lockbox_attributes
      return unless klass.respond_to?(:lockbox_attributes) && klass.lockbox_attributes.keys.any?
      klass.lockbox_attributes.keys
    end

    def table
      @table ||= klass.arel_table
    end

    def upsert_insert(attributes)
      insert_values = attributes.map { |key, value| [table[key], value] }
      Arel::InsertManager.new.insert(insert_values).to_sql
    end

    def upsert_update(attributes)
      set_values = attributes.without(target, :created_at).map { |key, value| [table[key], value] }
      manager = Arel::UpdateManager.new
        .table(table)
        .set(set_values)
        .where(table[:version].lt attributes[:version])

      manager.to_sql.sub(/^UPDATE "[^"]*"/, 'UPDATE')
    end

    def has_column?(name)
      klass.columns.any? { |column| column.name.to_s == name.to_s }
    end
  end
end
