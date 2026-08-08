module Recourse
  module Helpers
    # Helpers for the cells of a table and the fields of a form.
    module Cells
      # How a time reads on a page, e.g. 'Aug 4 at 03:47pm EDT'.
      TIME_FORMAT = '%b %-d at %I:%M%P %Z'

      # And a date, e.g. 'Aug 12, 2026'. A date column holds no time to say when in
      # the day, and `2026-08-12` is a value rather than something anyone reads.
      DATE_FORMAT = '%b %-d, %Y'

      # What Rails maintains rather than what a record is about, so a table ends with
      # these, in this order, whichever way round the schema happens to declare them.
      TIMESTAMPS = %w[created_at updated_at].freeze

      # Columns the table shows: every attribute that is not encrypted, less the
      # primary key — an id is how a row is addressed, not something to read about
      # it — and with the timestamps moved to the end, before the actions.
      def resource_columns
        hidden = Array(resource_model.encrypted_attributes).map(&:to_s)
        columns = resource_model.column_names - hidden - [resource_model.primary_key]

        (columns - TIMESTAMPS) + (TIMESTAMPS & columns)
      end

      # Columns a form offers, the same list `create` permits.
      def editable_columns
        Recourse.editable_columns resource_model
      end

      # Heading for a column, which a host app can translate like any attribute.
      def resource_column_title(column)
        resource_model.human_attribute_name column
      end

      # Value for one cell, formatted according to what the column holds.
      def resource_cell(resource, column)
        association = belongs_to_association column
        return search_highlight reference_cell(resource, association), column if association

        value = resource.attributes[column]

        return time_tag value, value.strftime(TIME_FORMAT) if value.is_a? Time
        # After Time, since a `DateTime` is a `Date` as well and would lose the time
        # it carries if this ran first. A zoned time is not a Date, so it is safe.
        return time_tag value, value.strftime(DATE_FORMAT) if value.is_a? Date
        return number_to_phone value if column == 'phone'
        # An array column would otherwise print its own inspect output, brackets and
        # quotes and all, and an empty one would read `[]` rather than as empty.
        return value.join ', ' if value.is_a? Array

        search_highlight value, column
      end

      # A value with the searched text marked, so a row says why it is in the table.
      # Only what the search looked through is marked: a word marked in a column
      # nobody searched would claim a match that never happened.
      def search_highlight(value, column)
        term = query_params[resource_model.search_field]
        return value if term.blank? || !searched_column?(column)

        highlight value.to_s, term
      end

      # One cell: a heading in the header row, the block's output in every other.
      def column(header:, **, &)
        return tag.th(header, scope: :col, **) if @recourse_headers

        tag.td(capture(&), 'data-cell': header, **)
      end

    private

      # A foreign key's cell shows a label from the other table, so what decides is
      # whether the search reaches through that association rather than reads a column.
      def searched_column?(column)
        association = belongs_to_association column.to_s
        return resource_model.recourse_searchable_associations.include? association if association

        resource_model.recourse_searchable_columns.include? column.to_s
      end
    end
  end
end
