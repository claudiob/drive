module Recourse
  module Helpers
    # Helpers for the cells of a table and the fields of a form.
    module Cells
      # How a time reads on a page, e.g. 'Aug 4 at 03:47pm EDT'.
      TIME_FORMAT = '%b %-d at %I:%M%P %Z'

      # Columns the table shows: every attribute that is not encrypted.
      def resource_columns
        resource_model.column_names - Array(resource_model.encrypted_attributes).map(&:to_s)
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
        value = resource.attributes[column]

        return time_tag value, value.strftime(TIME_FORMAT) if value.is_a? Time
        return number_to_phone value if column == 'phone'

        value
      end

      # One cell: a heading in the header row, the block's output in every other.
      def column(header:, **, &)
        return tag.th(header, scope: :col, **) if @recourse_headers

        tag.td(capture(&), 'data-cell': header, **)
      end
    end
  end
end
