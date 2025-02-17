require 'active_record'
require 'configure'
require 'mimic'

module Hubbado
  class UpsertVersion
    include Configure

    configure :upsert_version

    attr_reader :klass
    attr_reader :target
    attr_reader :version_column_name

    Error = Class.new(StandardError)

    Unchanged = Data.define do
      def unchanged? = true

      def inserted? = false
      def updated? = false
    end

    Inserted = Data.define(:attributes) do
      def unchanged? = false

      def inserted? = true
      def updated? = false
    end

    Updated = Data.define(:attributes) do
      def unchanged? = false

      def inserted? = false
      def updated? = true
    end

    def self.build(...)
      new(...)
    end

    def initialize(klass, target: nil, version_column_name: nil)
      target ||= klass.primary_key
      version_column_name ||= :version

      @klass = klass
      @target = Array.wrap(target).map(&:to_sym)
      @version_column_name = version_column_name
    end

    def call(attributes)
      encrypted = encrypted_attributes(attributes)
      casted = encrypted.to_h do |key, value|
        [key.to_sym, table[key].type_cast_for_database(value)]
      end

      if casted.values_at(*target, version_column_name).any?(&:blank?)
        raise Error, "Both target (#{target.join ', '}) and #{version_column_name} values" \
          " are required for upsert_version"
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
        "#{insert} ON CONFLICT (#{target.join(', ')}) DO #{update} RETURNING *, xmax"
      )
      attributes = result.to_a.first

      if attributes
        # If xmax = 0, it means the row was inserted.
        # If xmax > 0, it means the row was updated, and the value represents
        # the transaction ID that updated it.
        #
        # This method works because in PostgreSQL, xmax tracks the transaction
        # ID that deleted or updated a row. If the row is newly inserted, xmax
        # remains 0 since no prior transaction modified it.
        xmax = attributes.delete('xmax').to_i

        if xmax == 0
          Inserted.new(attributes)
        else
          Updated.new(attributes)
        end
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
        .where(
          table[version_column_name]
            .lt(attributes[version_column_name])
            .or(table[version_column_name].eq(nil))
        )

      manager.to_sql.sub(/^UPDATE "[^"]*"/, 'UPDATE')
    end

    def has_column?(name)
      klass.columns.any? { |column| column.name.to_s == name.to_s }
    end
  end
end
