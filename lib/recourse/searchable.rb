require 'active_support'

require_relative 'searchable/columns'
require_relative 'searchable/terms'

module Recourse
  # Extends every Active Record model with what Ransack asks of it, so an index
  # sorts, searches and filters before a model has said anything at all.
  module Searchable
    include Columns, Terms

    # How many rows a menu may hold before it stops being a menu. Fifty states are a
    # list to pick from; three thousand counties are a page of HTML nobody reads.
    MENU_LIMIT = 100

    # Attributes Ransack may read: every column that is not encrypted, plus the
    # encrypted ones a search can still match whole — `cont` reads ciphertext and
    # finds nothing, but a deterministic `eq` compares the same bytes every time.
    def ransackable_attributes(_auth_object = nil)
      (column_names - recourse_encrypted_names) + recourse_encrypted_searchable_columns
    end

    # Associations Ransack may reach through: the ones the search box looks into,
    # and no others, so a predicate joins another table only where one is searched.
    def ransackable_associations(_auth_object = nil)
      recourse_searchable_associations.map { |association| association.name.to_s }
    end

    # Columns a heading may sort by: the timestamps, and whatever an index covers,
    # so an ORDER BY walks a btree rather than sorting the table to answer. Never a
    # foreign key: its cell shows a label from the other table, and the id under it
    # is not the order that label reads in.
    def ransortable_attributes(_auth_object = nil)
      readable = ransackable_attributes - recourse_encrypted_names
      sortable = readable & (recourse_indexed_columns + %w[created_at updated_at])

      sortable - reflect_on_all_associations(:belongs_to).map { |one| one.foreign_key.to_s }
    end

    # Filters offered beside the search box, as a Ransack predicate to the options
    # that draw it — `label:` for its heading, `scope:` for the records it offers.
    # One per belongs_to, less the ones the search box reaches through instead: a
    # typed label says the other model is too big to draw a menu of.
    def filter_fields
      searched = recourse_searchable_associations
      reflect_on_all_associations(:belongs_to).filter_map do |association|
        ["#{association.foreign_key}_in", {}] unless searched.include? association
      end.to_h
    end

    # True where the index has anything to show above its table.
    def recourse_searchable? = search_field.present? || filter_fields.any?

    # True where a foreign key pointing here is typed rather than picked, which a
    # form and the controller reading its parameters back have to agree on: the label
    # is bounded, or the table is too long to list.
    def recourse_typed_reference? = recourse_typed_label? || !recourse_listable?

    # True where every row of this model could be listed in one menu. The count is
    # bounded, so the question costs the same on ten rows as on ten million, and it
    # is asked once per class — a table that crosses the line is noticed at boot.
    def recourse_listable?
      return @recourse_listable unless @recourse_listable.nil?

      @recourse_listable = limit(MENU_LIMIT + 1).count <= MENU_LIMIT
    end
  end
end

ActiveSupport.on_load :active_record do
  extend Recourse::Searchable
end
