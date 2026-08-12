module Recourse
  module Helpers
    # How one attribute reads on a page that only reads it.
    module Formats
      # A boolean is a picture rather than the words `true` and `false`, and a column
      # of them scans in one pass. The concept is named here and Unicon says what the
      # set calls it, the same way a model names its own icon.
      BOOLEAN_ICONS = { true => :check, false => :close, nil => :square }.freeze

      # What the record says for one column, formatted by what the column holds.
      def formatted_value(column)
        association = belongs_to_association column
        return reference_cell resource_record, association if association

        kind = attribute_kind column
        value = resource_record.attributes[column]
        return formatted_number kind, column, value if numeric_kind? kind

        formatted_text kind, value
      end

      # One icon, named by the concept it means rather than by what this set calls it.
      def icon_tag(concept, label: nil)
        tag.i class: "bi bi-#{Unicon[concept][:bootstrap]}", aria: { label: }
      end

    private

      def formatted_number(kind, column, value)
        case kind
        when :integer then number_with_delimiter value
        when :phone then number_to_phone value
        when :price then number_to_currency value, **precision_option(column)
        when :percentage then number_to_percentage value, **precision_option(column)
        when :decimal then number_with_precision value, **precision_option(column)
        else number_with_precision value
        end
      end

      def formatted_text(kind, value)
        case kind
        when :boolean then boolean_icon value
        when :enum then enum_badge value
        when :date, :datetime, :time then value && localized(value)
        else value.is_a?(Array) ? value.join(', ') : value
        end
      end

      # Labelled with the word it stands for: an icon alone says nothing to a screen
      # reader, and `true` and `false` are the words the table uses.
      def boolean_icon(value)
        icon_tag BOOLEAN_ICONS[value], label: value.to_s.presence || t('recourse.blank')
      end

      def enum_badge(value)
        value && tag.span(value, class: 'badge')
      end
    end
  end
end
