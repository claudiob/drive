require 'active_support'

module Recourse
  # Extends every Active Record model with what Ransack asks of it, so an index
  # sorts, searches and filters before a model has said anything at all.
  module Searchable
    # Column types a search box can match on containment. An enum is a Postgres
    # type of its own, and what it holds is a word, so it reads as a string too.
    SEARCHABLE_TYPES = %i[string text citext enum].freeze

    # Attributes Ransack may read: every column except the encrypted ones, since
    # no predicate can say anything true about ciphertext.
    def ransackable_attributes(_auth_object = nil)
      column_names - Array(encrypted_attributes).map(&:to_s)
    end

    # Associations Ransack may reach through: none, until a model names some. A
    # predicate on another table joins it, and nothing defaulted here does.
    def ransackable_associations(_auth_object = nil) = []

    # Columns a heading may sort by: the timestamps, and whatever an index covers,
    # so an ORDER BY walks a btree rather than sorting the table to answer.
    def ransortable_attributes(_auth_object = nil)
      ransackable_attributes & (recourse_indexed_columns + %w[created_at updated_at])
    end

    # The predicate a search box submits: every indexed string column at once, each
    # matched on containment. Nil where the model has no such column to look in.
    def search_field
      columns = recourse_searchable_columns
      return if columns.empty?

      "#{columns.join '_or_'}_cont"
    end

    # What the search box says while it is empty, naming what it looks through.
    def search_prompt
      columns = recourse_searchable_columns
      return if columns.empty?

      # Left as `human_attribute_name` returns it, since downcasing would spell a
      # registered acronym back out as a word: `zip`, where the heading reads `ZIP`.
      "Filter by #{columns.map { |column| human_attribute_name column }.join ' or '}"
    end

    # Filters offered beside the search box, as a Ransack predicate to the options
    # that draw it — `label:` for its heading, `scope:` for the records it offers.
    # One per belongs_to by default, so a table narrows to what it points at.
    def filter_fields
      reflect_on_all_associations(:belongs_to).to_h do |association|
        ["#{association.foreign_key}_in", {}]
      end
    end

    # Columns worth searching: the indexed strings. An index is the only signal a
    # schema carries about which column identifies a row rather than describes it.
    def recourse_searchable_columns
      types = attribute_types
      ransackable_attributes.intersection(recourse_indexed_columns).select do |column|
        SEARCHABLE_TYPES.include? types[column].type
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

    # True where the index has anything to show above its table.
    def recourse_searchable? = search_field.present? || filter_fields.any?
  end
end

ActiveSupport.on_load :active_record do
  extend Recourse::Searchable
end
