module Recourse
  module Helpers
    # Helpers for the cells of a table and the fields of a form.
    module Cells
      # What Rails maintains rather than what a record is about. A table ends with
      # whichever of these its model asks for, in this order, whichever way round the
      # schema happens to declare them.
      TIMESTAMPS = %w[created_at updated_at].freeze

      # Columns the table shows: every attribute that is not encrypted and not
      # read-only, less the primary key — an id is how a row is addressed, not
      # something to read about it — and with the timestamps moved to the end,
      # before the actions.
      def resource_columns
        columns = resource_model.column_names - hidden_columns
        asked = resource_model.recourse_timestamps.map(&:to_s)

        (columns - TIMESTAMPS) + (TIMESTAMPS & columns & asked)
      end

      # What no table shows: ciphertext nobody can read, a value written once that
      # belongs to the row's identity, the id that addresses it — and the parent a
      # nested route already names, which every row would repeat.
      def hidden_columns
        resource_model.recourse_encrypted_names +
          resource_model.readonly_attributes.to_a + [resource_model.primary_key] +
          Array(resource_parent_association&.foreign_key)
      end

      # Columns a form offers and a show page reads out — less the parent a nested
      # route has already answered: a comment under `/posts/2` is for post 2, not
      # for one picked from a menu, so no field asks.
      def editable_columns
        Recourse.editable_columns(resource_model) -
          Array(resource_parent_association&.foreign_key)
      end

      # Heading for a column, which a host app can translate like any attribute. A
      # counter is headed with what it counts — `ZIPs`, not `ZIPs count` — since the
      # column holds a number and the heading says what the number is of.
      def resource_column_title(column)
        counted = resource_model.recourse_counters[column]
        return resource_model.human_attribute_name column unless counted

        counted.klass.model_name.human.pluralize
      end

      # Value for one cell, formatted according to what the column holds.
      def resource_cell(resource, column)
        association = belongs_to_association column
        return search_highlight reference_cell(resource, association), column if association

        value = resource.attributes[column]
        counted = resource_model.recourse_counters[column]

        # A count leads with the icon of what it counts rather than the heading: a
        # column of figures is read down, and by then the heading is a scroll away.
        # It links to the counted rows where a block nested their index under here.
        return counter_cell resource, value, counted if counted

        formatted_cell value, column
      end

      # A date or a time, in words and in the attribute a machine reads. `l` picks
      # the date format or the time one by what it is handed, so nothing here has to
      # ask which it has — and a `DateTime`, which is both, still keeps its time.
      def localized(value)
        time_tag value, l(value, format: :recourse)
      end

      # One cell: a heading in the header row, the block's output in every other.
      def column(header:, **, &)
        return tag.th(header, scope: :col, **) if @recourse_headers

        tag.td(capture(&), 'data-cell': header, **)
      end

    private

      def counter_cell(resource, value, association)
        count = safe_join [tag.i(class: "bi bi-#{Recourse.model_icon association.klass}"), value],
                          ' '
        nested = "#{controller.controller_path}/#{association.name}"
        return count unless routed? nested, 'index'

        turbo_link_to count, url_for(controller: "/#{nested}", action: :index,
                                     "#{resource_key}_id": resource.id)
      end

      def formatted_cell(value, column)
        return localized value if value.is_a?(Date) || value.is_a?(Time)
        return number_to_phone value if column == 'phone'

        search_highlight value, column
      end
    end
  end
end
