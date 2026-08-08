module Recourse
  module Helpers
    # The menus beside a search box, one per foreign key a table can be narrowed by.
    module Filters
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
        # What the filter reads as when nothing is ticked, so the way back to it is a
        # line in the menu rather than unticking whatever was ticked.
        all = t 'recourse.all', models: recourses.klass.model_name.human.pluralize.downcase

        render 'recourses/combobox', name: "q[#{predicate}]", id: "q_#{predicate}",
                                     invalid: false, feedback: nil, label: label.to_s,
                                     placeholder: title, required: false, multiple: true,
                                     aria_label: title, selected: filter_values(predicate),
                                     recourses: recourses.select(:id, label).order(label),
                                     small: true, all: all
      end

      # A multiple combobox submits one input holding every value it was given, so
      # what a menu shows as chosen is read back out of the same comma-joined string.
      def filter_values(predicate)
        query_params[predicate].to_s.split ','
      end
    end
  end
end
