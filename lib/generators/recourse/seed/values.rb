module Recourse
  module Generators
    # What one seed cell is worth: a Ruby literal of the column's own kind, drawn
    # at random while generating — the written file then never changes between
    # `db:seed` runs, which is what keeps `find_or_create_by!` finding its rows.
    # Private for the reason `Seeds` is.
    module Values
      # A value of each kind of column, random within a shape the column accepts.
      # A decimal stays under ten, so any precision two steps over its scale fits.
      VALUES = {
        integer: -> { rand(100).to_s },
        float: -> { "#{rand 100}.#{rand 10}" },
        decimal: -> { "#{rand 1..9}.#{rand 10}" },
        boolean: -> { [true, false].sample.to_s },
        date: -> { "Date.current - #{rand 365}" },
        datetime: -> { "Time.current - #{rand 1..9000}.hours" },
      }.freeze

      # What an app's own type is a kind of — a Price is a Decimal however it
      # answers `type` — for the columns whose `type` names no entry above.
      KINDS = {
        ActiveModel::Type::Integer => :integer, ActiveModel::Type::Float => :float,
        ActiveModel::Type::Decimal => :decimal, ActiveModel::Type::Boolean => :boolean,
        ActiveModel::Type::Date => :date, ActiveModel::Type::DateTime => :datetime,
      }.freeze

    private

      def seed_pair(column, number)
        association = seed_association column
        return "#{association.name}: #{seed_reference association}" if association

        "#{column}: #{seed_value column, number}"
      end

      # A random row of the other table, picked while generating: `db:seed` then
      # reads the same row every run, which a sample at seed time would not.
      def seed_reference(association)
        rows = association.klass.count
        return "#{association.klass.name}.first" if rows < 2

        "#{association.klass.name}.offset(#{rand rows}).first"
      end

      # A Ruby literal for one cell: an enum cycles the words it admits, and
      # everything else is `VALUES`' business.
      def seed_value(column, number)
        words = @model.defined_enums[column]
        return ":#{words.keys[(number - 1) % words.size]}" if words

        seed_literal column, @model.type_for_attribute(column)
      end

      def seed_association(column)
        @model.reflect_on_all_associations(:belongs_to)
              .find { |association| association.foreign_key.to_s == column }
      end

      def seed_literal(column, type)
        kind = VALUES.key?(type.type) ? type.type : KINDS.find { |klass, _| type.is_a? klass }&.last

        VALUES.fetch(kind) { -> { seed_string column } }.call
      end
    end
  end
end
