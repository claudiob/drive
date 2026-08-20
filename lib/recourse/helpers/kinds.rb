module Recourse
  module Helpers
    # What an attribute holds, which is the one question a value and a field are both
    # answers to.
    module Kinds
      # Numbers, which differ by what they are of rather than by how they are stored.
      NUMERIC_KINDS = %i[integer decimal float phone price percentage].freeze

      # A payload, under both names an adapter has for one: SQLite and MySQL report a
      # JSON column as `json`, and PostgreSQL's own type reports `jsonb`. Two names for
      # the thing a page does the same with, so the gem asks for either.
      JSON_KINDS = %i[json jsonb].freeze

    private

      # Whether a kind is one of those, which is what both pages branch on first.
      def numeric_kind?(kind) = NUMERIC_KINDS.include?(kind)

      # Asked in the order that settles it. A counter cache is a counter whatever its
      # column says, since no page may show one and no form may set one; an enum is
      # one however it is stored; a phone is a phone by its name, the convention the
      # placeholders and the pattern already follow; and everything else is the type
      # the attribute itself reports — `:price` included, where a host has registered
      # a type that says so.
      def attribute_kind(column)
        return :counter if resource_model.recourse_counters.key? column
        return :enum if resource_model.defined_enums.key? column
        return :phone if column == 'phone'

        attribute_type column
      end

      # The model's own attribute type, so an `attribute` override still counts and
      # `columns_hash` is never asked.
      def attribute_type(column)
        resource_model.type_for_attribute(column).type
      end

      # Columns holding JSON, under whichever name this adapter reports. A payload is a
      # service's answer kept whole — machinery rather than anything a row is about —
      # and one of them is as wide as a page, so no table draws one until a model names
      # it back. Asked through `type_for_attribute` like every other kind, so an
      # `attribute` override counts here too.
      def json_columns
        resource_model.column_names.select { |column| JSON_KINDS.include? attribute_type(column) }
      end

      # How many decimals the attribute keeps, and how many digits in all. Read from
      # the type rather than the column, and nil for anything that never said.
      def attribute_scale(column)
        resource_model.type_for_attribute(column).scale
      end

      # Total digits the attribute holds, the scale included.
      def attribute_precision(column)
        resource_model.type_for_attribute(column).precision
      end

      # What to round a number to, where the attribute says how much it keeps.
      def precision_option(column)
        scale = attribute_scale column
        scale ? { precision: scale } : {}
      end
    end
  end
end
