module Recourse
  # View helpers for the pages the gem renders.
  module Helpers
    # How a time reads on a page, e.g. 'Aug 4 at 03:47pm EDT'.
    TIME_FORMAT = '%b %-d at %I:%M%P %Z'

    # Human, plural name of the resource on the page, e.g. 'Contacts'.
    def resources_name
      controller.controller_name.humanize
    end

    # Columns the table shows: every attribute that is not encrypted.
    def resource_columns
      resource_model.column_names - Array(resource_model.encrypted_attributes).map(&:to_s)
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

    # One cell: a heading in the header row, a labelled value in every other.
    def column(header:, value: nil, heading: false, **)
      return tag.th(header, scope: :col, **) if heading

      tag.td(value, 'data-cell': header, **)
    end

  private

    def resource_model
      controller.controller_name.classify.constantize
    end
  end
end
