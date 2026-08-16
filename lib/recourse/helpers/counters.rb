module Recourse
  module Helpers
    # A counter cache's column in a table: an icon heading over bare figures.
    module Counters
      # The class a counter's cells carry, which is what sizes the column like the
      # action columns beside it rather than like the columns carrying text.
      def counter_class(column)
        'recourse-counter' if resource_model.recourse_counters.key? column
      end

    private

      def counter_cell(resource, value, association)
        # Delimited like every other count on the page: the filter menu beside the
        # table already reads 38,405, and one figure in two spellings reads as two.
        count = number_with_delimiter value
        nested = "#{resource_controller_path}/#{association.name}"
        return count unless routed? nested, 'index'

        turbo_link_to count, url_for(controller: "/#{nested}", action: :index,
                                     "#{resource_key}_id": resource.id)
      end

      # The icon the sidebar and the breadcrumb already draw for the counted model,
      # speaking the heading's word to a screen reader.
      def counter_title(association)
        title = Recourse.model_title association.klass
        tag.i class: "bi bi-#{Recourse.model_icon association.klass}", role: :img,
              aria: { label: title }, data: tooltip_on_top(title)
      end

      def counter_columns
        resource_model.recourse_counters.keys
      end
    end
  end
end
