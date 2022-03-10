require "hubbado/upsert_version/version"
require 'active_record'

module Hubbado
  class UpsertVersion
    Error = Class.new(StandardError)

    def initialize(klass, target: klass.primary_key)
      @klass = klass
      @target = Array.wrap(target).map &:to_sym
    end

    def call(attributes)
      encrypted = encrypted_attributes(attributes)
      casted = encrypted.map do |key, value|
        [key.to_sym, table[key].type_cast_for_database(value)]
      end.to_h

      if casted.values_at(*target, :version).any?(&:blank?)
        raise Error, "Both target (#{target.join ', '}) and version values are required for upsert_version"
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

      ActiveRecord::Base.connection.execute "#{insert} ON CONFLICT (#{target.join(', ')}) DO #{update}"
    end

    private

    attr_reader :klass, :target

    def encrypted_attributes(attributes)
      return attributes unless klass_encrypted_attributes
      attributes_for_encryption = attributes.slice(*klass_encrypted_attributes)

      encrypted_record = klass.new(attributes_for_encryption)
      encrypted_attribtues = attributes_for_encryption.keys.map do |key|
        {
          "encrypted_#{key}" => encrypted_record.send("encrypted_#{key}"),
          "encrypted_#{key}_salt" => encrypted_record.send("encrypted_#{key}_salt"),
          "encrypted_#{key}_iv" => encrypted_record.send("encrypted_#{key}_iv")
        }
      end.reduce(:merge) || {}

      attributes.except(*attributes_for_encryption.keys).merge(encrypted_attribtues)
    end

    def klass_encrypted_attributes
      if klass.respond_to?(:attr_encrypted_encrypted_attributes) &&
         klass.attr_encrypted_encrypted_attributes.keys.any?
        klass.attr_encrypted_encrypted_attributes.keys
      elsif klass.respond_to?(:encrypted_attributes) &&
            klass.encrypted_attributes.keys.any?
        klass.encrypted_attributes.keys
      end
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
      klass.columns.any? { |column| column.name.to_s == name .to_s}
    end
  end
end
