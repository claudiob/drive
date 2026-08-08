module Recourse
  module Searchable
    # What the search box above a table submits, and what it says while it is empty.
    module Terms
      # The predicate a search box submits: everything it looks through at once,
      # joined by `or`. Nil where a model has nothing worth looking through, which
      # is also what leaves that model without a search box.
      def search_field
        fields, predicate = recourse_search_terms
        return if fields.empty?

        "#{fields.join '_or_'}_#{predicate}"
      end

      # What a search box looks through, and how it matches: the plaintext columns
      # and the labels behind foreign keys, on containment — or, for a model that
      # keeps nothing in plaintext worth searching, its encrypted columns, whole.
      def recourse_search_terms
        plain = recourse_searchable_columns + recourse_searchable_references
        return [plain, 'cont'] if plain.any?

        [recourse_encrypted_searchable_columns, 'eq']
      end

      # What the search box says while it is empty, naming what it looks through.
      def search_prompt
        fields, predicate = recourse_search_terms
        return if fields.empty?

        I18n.t "recourse.searched_#{predicate}", list: recourse_search_names.join(' or ')
      end

      # Those same terms as words: a column by its attribute name, a foreign key by
      # what a form and a table already call it.
      def recourse_search_names
        plain = recourse_searchable_columns.map { |column| human_attribute_name column } +
                recourse_searchable_associations.map { |one| one.klass.recourse_reference_name }
        return plain if plain.any?

        recourse_encrypted_searchable_columns.map { |column| human_attribute_name column }
      end
    end
  end
end
