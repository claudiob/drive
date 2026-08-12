module Recourse
  module Helpers
    # What an attribute holds, which is the one question a value and a field are both
    # answers to.
    module Kinds
      # Numbers, which differ by what they are of rather than by how they are stored.
      NUMERIC_KINDS = %i[integer decimal float phone price percentage].freeze

      # Whether a kind is one of those, which is what both pages branch on first.
      def numeric_kind?(kind) = NUMERIC_KINDS.include?(kind)

      # Asked in the order that settles it. A counter cache is a counter whatever its
      # column says, since no page may show one and no form may set one; what the
      # model declares outranks the schema, because no column type says `price`; an
      # enum is one however it is stored; and a phone is a phone by its name, the
      # convention the placeholders and the pattern already follow.
      def attribute_kind(column)
        return :counter if resource_model.recourse_counters.key? column

        declared = resource_model.recourse_formats[column.to_sym]
        return declared if declared
        return :enum if resource_model.defined_enums.key? column
        return :phone if column == 'phone'

        attribute_type column
      end

      # The model's own attribute type, so an `attribute` override still counts and
      # `columns_hash` is never asked.
      def attribute_type(column)
        resource_model.type_for_attribute(column).type
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
