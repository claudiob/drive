module Recourse
  module Searchable
    # What a model's own schema offers a search: which of its columns are worth
    # looking through, and which of its foreign keys are worth looking past.
    module Columns
      # Column types a search box can match on containment. An enum is a Postgres
      # type of its own, and what it holds is a word, so it reads as a string too.
      SEARCHABLE_TYPES = %i[string text citext enum].freeze

      # Columns worth searching: the indexed strings. An index is the only signal a
      # schema carries about which column identifies a row rather than describes it.
      def recourse_searchable_columns
        types = attribute_types
        ransackable_attributes.intersection(recourse_indexed_columns).select do |column|
          SEARCHABLE_TYPES.include? types[column].type
        end
      end

      # Foreign keys a search reaches through rather than filters by: the ones whose
      # label is typed, since a menu of every row is what a typed label means the
      # other model is too big for. The label has to be searchable on that model
      # too — indexed, and a string — or there is nothing to reach for.
      def recourse_searchable_associations
        reflect_on_all_associations(:belongs_to).select do |association|
          klass = association.klass
          klass.recourse_typed_label? &&
            klass.recourse_searchable_columns.include?(klass.recourse_label.to_s)
        end
      end

      # Those foreign keys as Ransack names them: `zip_code`, for the ZIP that
      # `/locations` asks to be typed rather than picked out of 40,965 options.
      def recourse_searchable_references
        recourse_searchable_associations.map do |association|
          "#{association.name}_#{association.klass.recourse_label}"
        end
      end

      # `ZIP code`, the way a form and a table already head the same foreign key.
      def recourse_reference_name(association)
        klass = association.klass

        "#{klass.model_name.human} #{klass.human_attribute_name(klass.recourse_label).downcase}"
      end

      # Columns an index covers, the primary key among them. Read from the schema
      # cache, so asking costs nothing after the first look.
      def recourse_indexed_columns
        indexes = connection_pool.schema_cache.indexes table_name
        # An expression index reports a string rather than a list of columns, and it
        # names no column an ORDER BY could use, so intersecting drops it.
        column_names.intersection [primary_key, *indexes.flat_map { |one| Array one.columns }]
      end
    end
  end
end
