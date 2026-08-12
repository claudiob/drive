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
        return enum_filter predicate, column, label if resource_model.defined_enums.key? column

        association = belongs_to_association column
        return if association.nil? || (scope.nil? && association.klass.recourse_typed_label?)

        filter_combobox predicate, label || reference_title(column, association),
                        (scope || association.klass).all
      end

    private

      # A menu of the words the column admits, which are the words the form's own menu
      # offers and the badge on a show page reads. Headed by the attribute rather than
      # by a model, since a status is the table's own and not another table's.
      def enum_filter(predicate, column, label)
        title = label || resource_model.human_attribute_name(column)
        values = resource_model.defined_enums[column].keys

        filter_menu predicate, title, values, enum_all(column)
      end

      # The way back to no filter at all, named after the column: `All statuses`.
      def enum_all(column)
        t 'recourse.all', models: Recourse.downcase(
          resource_model.human_attribute_name(column)
        ).pluralize
      end

      def filter_combobox(predicate, title, recourses)
        label = recourses.klass.recourse_label
        # What the filter reads as when nothing is ticked, so the way back to it is a
        # line in the menu rather than unticking whatever was ticked.
        models = Recourse.downcase recourses.klass.model_name.human.pluralize

        filter_menu predicate, title, nil, t('recourse.all', models: models),
                    label: label.to_s,
                    recourses: recourses.select(:id, label).order(label)
      end

      def filter_menu(predicate, title, values, all, **)
        render('recourses/combobox', name: "q[#{predicate}]", id: "q_#{predicate}",
                                     invalid: false, feedback: nil, placeholder: title,
                                     required: false, multiple: true, aria_label: title,
                                     selected: filter_values(predicate), small: true,
                                     all: all, values: Array(values), **)
      end

      # A multiple combobox submits one input holding every value it was given, so
      # what a menu shows as chosen is read back out of the same comma-joined string.
      def filter_values(predicate)
        query_params[predicate].to_s.split ','
      end
    end
  end
end
