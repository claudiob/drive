module Recourse
  module Helpers
    # The form above a table, and the links in the headings of one.
    module Searches
      # Caret for the direction a column is sorted by. A column nobody sorted by
      # gets none: an arrow on every heading says nothing about the order in force.
      SORT_CARETS = { 'asc' => 'caret-up-fill', 'desc' => 'caret-down-fill' }.freeze

      # A heading for a column: a link that sorts the table by it where the model
      # allows that, and the plain title everywhere else. Only the header row draws
      # the link, so the `data-cell` on every other row stays readable text.
      #
      # Named apart from Ransack's `sort_link`, which it calls: sharing the name
      # would take that helper away from every view this gem's controllers render.
      def sort_header(column, title = nil)
        title ||= sort_title column
        return title unless @recourse_headers && sortable_column?(column)

        sort_link resource_search, column.to_sym, hide_indicator: true, page: nil do
          safe_join [title, sort_caret(column)].compact, ' '
        end
      end

      # The form that searches and filters the table, or nothing at all where the
      # model offers neither a search field nor a filter to draw.
      def search_form
        return unless resource_model.recourse_searchable?

        render 'recourses/search', query: resource_search, url: url_for(action: :index),
                                   field: resource_model.search_field,
                                   prompt: resource_model.search_prompt,
                                   filters: resource_model.filter_fields, sort: sort_param
      end

      # A value with the searched text marked, so a row says why it is in the table.
      # Only what the search looked through is marked: a word marked in a column
      # nobody searched would claim a match that never happened.
      def search_highlight(value, column)
        term = query_params[resource_model.search_field]
        return value if term.blank? || !searched_column?(column)

        highlight value.to_s, term
      end

    private

      # A foreign key's cell shows a label from the other table, so what decides is
      # whether the search reaches through that association rather than reads a column.
      def searched_column?(column)
        association = belongs_to_association column.to_s
        return resource_model.recourse_searchable_associations.include? association if association

        resource_model.recourse_searchable_columns.include? column.to_s
      end

      # The heading a form and a table already agree on for the same column.
      def sort_title(column)
        reference_title column.to_s, belongs_to_association(column.to_s)
      end

      def sortable_column?(column)
        resource_model.ransortable_attributes.include? column.to_s
      end

      def sort_caret(column)
        sort = resource_search.sorts.find { |one| one.name == column.to_s }
        icon = SORT_CARETS[sort&.dir]
        return unless icon

        tag.i class: "bi bi-#{icon}"
      end

      # Carried through the form as a hidden field, so searching keeps the order a
      # heading asked for. Ransack's own links write one sort, and write it as a
      # string; an array from anywhere else is left behind rather than mangled.
      def sort_param
        sort = query_params[:s]
        sort if sort.is_a? String
      end

      # The search the action built, read from the assigns rather than by ivar name.
      def resource_search
        controller.view_assigns['q']
      end
    end
  end
end
