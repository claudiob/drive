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

    # Columns a heading may sort by: the timestamps, whatever an index covers, and
    # every counter cache — a count is a number a reader ranks by, and the one column
    # whose heading says what it counts. Never a foreign key: its cell shows a label
    # from the other table, and the id under it is not the order that label reads in.
    # And never one the model hides, for the reason `recourse_searchable_columns` gives
    # for leaving those out too: hidden from every screen means hidden here.
    def ransortable_attributes(_auth_object = nil)
      readable = ransackable_attributes - recourse_encrypted_names
      indexed = recourse_indexed_columns + recourse_counters.keys + Recourse::TIMESTAMPS

      keys = recourse_references.map { |one| one.foreign_key.to_s }

      (readable & indexed) - keys - Recourse.hidden_columns(self)
    end

    # Filters offered beside the search box, as a Ransack predicate to the options
    # that draw it — `label:` for its heading, `scope:` for the records it offers.
    # One per enum, one per boolean, then one per belongs_to, less the ones the
    # search box reaches through instead: a typed label says the other model is too
    # big to list. The model's own columns come first, before the menus that name
    # other tables.
    def filter_fields
      enum_filter_fields.merge(boolean_filter_fields).merge reference_filter_fields
    end

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

  private

    # One per enum: a dozen words a column admits are a menu whatever else is on the
    # page, and `_in` is what lets a request tick more than one of them.
    def enum_filter_fields
      defined_enums.keys.index_with({}).transform_keys { |name| "#{name}_in" }
    end

    # One per boolean: a column admitting two values is a menu for the same reason a
    # dozen words are, and the two are the type's own rather than anything declared.
    def boolean_filter_fields
      booleans = column_names - Recourse.hidden_columns(self)

      booleans.select { |one| type_for_attribute(one).type == :boolean }
              .index_with({}).transform_keys { |name| "#{name}_in" }
    end

    # One per belongs_to the search box does not reach through instead.
    def reference_filter_fields
      searched = recourse_searchable_associations
      recourse_references.filter_map do |association|
        ["#{association.foreign_key}_in", {}] unless searched.include? association
      end.to_h
    end
  end
end

ActiveSupport.on_load :active_record do
  extend Recourse::Searchable
end
