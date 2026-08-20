module Recourse
  module Helpers
    # A counter cache's column in a table: an icon heading over bare figures.
    module Counters
    private

      # The class a counter's cells carry, which is what sizes the column like the
      # action columns beside it rather than like the columns carrying text.
      def counter_class(column)
        'recourse-counter' if resource_model.recourse_counters.key? column
      end

      # A figure, and the word saying what it counts. The heading says that word too,
      # but by the twentieth row the heading has scrolled off — so the tooltip repeats
      # it where the cursor is. The `aria-label` carries both, since a link whose whole
      # text is a number announces as `10` and nothing else. A span where there is no
      # index to link to, so an unlinked count is named the same as a linked one.
      def counter_cell(resource, value, association)
        # Delimited like every other count on the page: the filter menu beside the
        # table already reads 38,405, and one figure in two spellings reads as two.
        count = number_with_delimiter value
        named = counter_naming count, association
        path = resource_controller_path
        nested = nested_path_of path, association
        return tag.span(count, **named) unless nested && routed?(nested, 'index')

        turbo_link_to count, nested_url(resource, path, nested, :index), **named
      end

      # The tooltip reads the word alone — the figure is already on the page — and the
      # label reads both, which is the order somebody hearing it needs them in.
      def counter_naming(count, association)
        title = Recourse.model_title association.klass

        { aria: { label: "#{count} #{title}" }, data: tooltip_on_top(title) }
      end

      # Where the counted rows were nested under this resource, read off the routes
      # rather than joined onto the parent's path: a `namespace` between the two is
      # part of the address and nothing here would know to put it back.
      def nested_path_of(path, association)
        Recourse.nested_under(path).find { |one| one.split('/').last == association.name.to_s }
      end

      # The icon the sidebar and the breadcrumb already draw for the counted model,
      # speaking the heading's word to a screen reader.
      def counter_title(association)
        icon_heading association.klass.recourse_icon, Recourse.model_title(association.klass)
      end

      def counter_columns
        resource_model.recourse_counters.keys
      end
    end
  end
end
