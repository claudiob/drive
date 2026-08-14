module Recourse
  module Generators
    # What one model's seed rows are made of: hashes mixing which optional
    # attributes are filled. Private for the reason `Seeds` is.
    module Rows
      # How many rows each file holds: the first bare, the last full, and the rest
      # cycling through combinations of the optional attributes.
      ROWS = 25

      # Validators that reject nil, so a row cannot save without the attribute:
      # `inclusion: { in: [true, false] }` is how a required boolean is asked for.
      REQUIRING = [
        ActiveModel::Validations::PresenceValidator,
        ActiveModel::Validations::InclusionValidator,
      ].freeze

    private

      # One `key: value` string per row, ready for a hash literal.
      def seed_rows
        (1..ROWS).map do |number|
          seed_columns(number).map { |column| seed_pair column, number }.join ', '
        end
      end

      # Which columns row `number` fills: every required one, plus the optional
      # ones whose bit is set in the row's own number — so the combinations differ
      # row to row, the first row is the bare minimum and the last fills everything.
      def seed_columns(number)
        optionals = seed_optionals
        return seed_editable if number == ROWS

        seed_editable.select do |column|
          !optionals.include?(column) || (number - 1)[optionals.index(column)] == 1
        end
      end

      def seed_editable
        Recourse.editable_columns @model
      end

      def seed_optionals
        seed_editable.reject { |column| seed_required? column }
      end

      # What the bare row cannot leave out: a column the model validates against
      # nil, or one the database itself refuses NULL in with no default to answer
      # for it. Both gates stand between a row and saving, so both are asked.
      def seed_required?(column)
        seed_validated?(column) || seed_constrained?(column)
      end

      # A belongs_to validates the association rather than the column, so `zip_id`
      # asks about `zip` too.
      def seed_validated?(column)
        [column, column.delete_suffix('_id')].uniq.any? do |attribute|
          @model.validators_on(attribute).any? do |validator|
            REQUIRING.any? { |kind| validator.is_a? kind }
          end
        end
      end

      def seed_constrained?(column)
        one = @model.columns_hash[column]

        !one.null && one.default.nil? && one.default_function.nil?
      end
    end
  end
end
