module Recourse
  module Generators
    # What one seed cell is worth: a Ruby literal of the column's own kind, varied
    # by the row's number. Private for the reason `Seeds` is.
    module Values
      # A value of each kind of column, numbered so 25 rows can satisfy a unique
      # index without a validator's help. No bare `time` — the dummy app has no
      # such column, so the entry would be a lambda nothing runs; it is one line
      # to restore beside a column that wants it.
      VALUES = {
        integer: :to_s.to_proc,
        float: ->(number) { "#{number}.5" }, decimal: ->(number) { "#{number}.5" },
        boolean: ->(number) { number.even?.to_s },
        date: ->(number) { "Date.current - #{number}" },
        datetime: ->(number) { "Time.current - #{number}.hours" },
      }.freeze

      # What an app's own type is a kind of — a Price is a Decimal however it
      # answers `type` — for the columns whose `type` names no entry above.
      KINDS = {
        ActiveModel::Type::Integer => :integer, ActiveModel::Type::Float => :float,
        ActiveModel::Type::Decimal => :decimal, ActiveModel::Type::Boolean => :boolean,
        ActiveModel::Type::Date => :date, ActiveModel::Type::DateTime => :datetime,
      }.freeze

    private

      # A reference is keyed by its association and reads the first row of what it
      # points at; every other column is keyed by its own name.
      def seed_pair(column, number)
        association = seed_association column
        return "#{association.name}: #{association.klass.name}.first" if association

        "#{column}: #{seed_value column, number}"
      end

      # A Ruby literal for one cell: an enum cycles the words it admits, an array
      # wraps its own base type, and everything else is `VALUES`' business.
      def seed_value(column, number)
        words = @model.defined_enums[column]
        return ":#{words.keys[(number - 1) % words.size]}" if words

        type = @model.type_for_attribute column
        return "[#{seed_literal column, number, type.subtype}]" if seed_array? type

        seed_literal column, number, type
      end

      def seed_association(column)
        @model.reflect_on_all_associations(:belongs_to)
              .find { |association| association.foreign_key.to_s == column }
      end

      def seed_array?(type)
        type.is_a? ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array
      end

      def seed_literal(column, number, type)
        kind = VALUES.key?(type.type) ? type.type : KINDS.find { |klass, _| type.is_a? klass }&.last

        VALUES.fetch(kind) { ->(one) { seed_string column, one } }.call number
      end

      # An email column gets an address and a phone column ten valid digits, since
      # both are the string shapes a model is nearly certain to grow a validator for.
      def seed_string(column, number)
        return "'#{column}#{number}@example.com'" if column.end_with? 'email'
        return "'555234#{format '%04d', number}'" if column.end_with? 'phone'

        "'#{column.humanize} #{number}'"
      end
    end
  end
end
