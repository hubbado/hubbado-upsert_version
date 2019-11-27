require "upsert_version/version"
require 'active_record'

class UpsertVersion
  Error = Class.new(StandardError)

  def initialize(klass, target: klass.primary_key)
    @klass = klass
    @target = Array.wrap(target).map &:to_sym
  end

  def call(attributes)
    casted = attributes.map do |key, value|
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
