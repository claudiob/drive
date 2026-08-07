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

      # One filter: a menu of the records a foreign key points at, holding whichever
      # of them the request already asked for. Nothing where that key's label is
      # typed rather than picked, since the menu would be a table of its own — the
      # judgement a form makes too. Naming a `scope:` is what draws one anyway.
      def filter_field(predicate, label: nil, scope: nil)
        column = predicate.to_s.sub Search::LIST_PREDICATES, ''
        association = belongs_to_association column
        return if association.nil? || (scope.nil? && association.klass.recourse_typed_label?)

        filter_combobox predicate, label || reference_title(column, association),
                        (scope || association.klass).all
      end

    private

      def filter_combobox(predicate, title, recourses)
        label = recourses.klass.recourse_label

        render 'recourses/combobox', name: "q[#{predicate}]", id: "q_#{predicate}",
                                     invalid: false, feedback: nil, label: label.to_s,
                                     placeholder: title, required: false, multiple: true,
                                     aria_label: title, selected: filter_values(predicate),
                                     recourses: recourses.select(:id, label).order(label),
                                     small: true
      end

      # A multiple combobox submits one input holding every value it was given, so
      # what a menu shows as chosen is read back out of the same comma-joined string.
      def filter_values(predicate)
        query_params[predicate].to_s.split ','
      end

      # `?q=anything` arrives as a String, which has no parameters to read.
      def query_params
        params[:q].respond_to?(:dig) ? params[:q] : {}
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
