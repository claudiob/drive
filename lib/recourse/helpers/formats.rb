module Recourse
  module Helpers
    # How one attribute reads on a page that only reads it.
    module Formats
      # One absolute web address and nothing else: a value to follow, not to read.
      # Anything around it — words, a second address — reads as text instead.
      WEB_URL = %r{\Ahttps?://\S+\z}

      # What the record says for one column, formatted by what the column holds.
      def formatted_value(column)
        association = belongs_to_association column
        return reference_cell resource_record, association if association

        formatted_attribute column, resource_record.attributes[column]
      end

      # One value, formatted by the kind its column holds — the one ladder a table
      # cell and a show page's value both come down, so a boolean is the same icon
      # and an enum the same badge on either. A block, where the caller has one,
      # marks the search terms inside whichever arm ends up as words.
      def formatted_attribute(column, value, &)
        kind = attribute_kind column
        return formatted_number kind, column, value if numeric_kind? kind

        formatted_text kind, value, &
      end

      # One icon, named by the concept it means rather than by what this set calls it.
      # Whatever else the caller hands over — a role, a tooltip's data — rides along.
      def icon_tag(concept, label: nil, **)
        tag.i class: "bi bi-#{Unicon[concept][:bootstrap]}", aria: { label: }, **
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

      def formatted_text(kind, value, &)
        case kind
        when :enum then value && enum_badge(marked(value, &))
        when :date, :datetime, :time then value && localized(value)
        else web_url?(value) ? url_link(value) : marked(value, &)
        end
      end

      # The caller's own marking, where it has one: a table marks what a search
      # matched, and a show page, which no search reached, has nothing to mark.
      def marked(value, &)
        block_given? ? yield(value) : value
      end

      # A date or a time, in words and in the attribute a machine reads. `l` picks
      # the date format or the time one by what it is handed, so nothing here has to
      # ask which it has — and a `DateTime`, which is both, still keeps its time.
      def localized(value)
        time_tag value, l(value, format: :recourse)
      end

      def enum_badge(value)
        tag.span value, class: 'badge'
      end

      def web_url?(value)
        value.is_a?(String) && value.match?(WEB_URL)
      end

      def url_link(value)
        # Bootstrap's icon link, in its hover style: the arrow walks a step under
        # the cursor, saying the value leads somewhere the way plain text cannot.
        tag.a safe_join([value, icon_tag(:point_right)], ' '),
              href: value, class: 'icon-link icon-link-hover'
      end
    end
  end
end
