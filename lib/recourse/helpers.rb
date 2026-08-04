module Recourse
  # View helpers for the pages the gem renders.
  module Helpers
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

  private

    def resource_model
      controller.controller_name.classify.constantize
    end
  end
end
