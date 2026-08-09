module Recourse
  module Searchable
    # What a model's own schema offers a search: which of its columns are worth
    # looking through, and which of its foreign keys are worth looking past.
    module Columns
      # Column types a search box can match on containment. An enum is a Postgres
      # type of its own, and what it holds is a word, so it reads as a string too.
      SEARCHABLE_TYPES = %i[string text citext enum].freeze

      # Columns worth searching: the indexed strings a table also shows. An index is
      # the only signal a schema carries about which column identifies a row rather
      # than describes it, and a column no page draws is not one to search by — a row
      # would arrive with nothing on it explaining why.
      def recourse_searchable_columns
        recourse_indexed_strings - recourse_encrypted_names - readonly_attributes.to_a
      end

      # The same columns where they are encrypted, which a search matches whole
      # rather than by containment: a LIKE reads ciphertext and matches nothing,
      # while a deterministic value encrypts to the same bytes every time, so `=`
      # still finds it. A column encrypted any other way is left out, since two
      # writes of one address do not compare equal.
      def recourse_encrypted_searchable_columns
        columns = (recourse_indexed_strings & recourse_encrypted_names) - readonly_attributes.to_a
        columns.select do |column|
          type_for_attribute(column).scheme.deterministic?
        end
      end

      # Every indexed column whose value is a word, whether or not it is encrypted.
      def recourse_indexed_strings
        types = attribute_types
        column_names.intersection(recourse_indexed_columns).select do |column|
          SEARCHABLE_TYPES.include? types[column].type
        end
      end

      # The attributes Active Record Encryption holds, as column names.
      def recourse_encrypted_names
        Array(encrypted_attributes).map(&:to_s)
      end

      # Foreign keys a search reaches through rather than filters by: the ones whose
      # other model is too long to list, since a menu is only a control while every
      # row fits in one. The label has to be a word for the search to match, too.
      def recourse_searchable_associations
        reflect_on_all_associations(:belongs_to).select do |association|
          klass = association.klass
          !klass.recourse_listable? && klass.recourse_searchable_label?
        end
      end

      # True where the label is a column a `cont` can match. Reaching through a
      # foreign key to compare an id or a date against typed text says nothing.
      def recourse_searchable_label?
        type = attribute_types[recourse_label.to_s]

        SEARCHABLE_TYPES.include? type&.type
      end

      # Those foreign keys as Ransack names them: `zip_code`, for the ZIP that
      # `/locations` asks to be typed rather than picked out of 40,965 options.
      def recourse_searchable_references
        recourse_searchable_associations.map do |association|
          "#{association.name}_#{association.klass.recourse_label}"
        end
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
