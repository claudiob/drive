require 'active_support'

module Recourse
  # Extends every Active Record model, so each one says how it is labelled, what
  # its index eager-loads and how that index is sorted.
  module Recoursive
    # Column a combobox shows for a record, and selects alongside its id.
    def recourse_label = :name

    # The concept a resource is drawn with, which Unicon names in each icon set it
    # knows. A model's own name by default — `contact` draws a rolodex, `job` a hammer
    # — and Unicon answers with a circle for a name it has never heard of.
    def recourse_icon = model_name.singular.to_sym

    # Which of `created_at` and `updated_at` a table ends with, in that order.
    # Neither by default: a timestamp is a fact about the row's storage rather than
    # about the thing it stores, and reference data written once by a migration
    # carries the same instant on every row of it.
    def recourse_timestamps = []

    # What a column holds that no column type can say: `:price` and `:percentage`, per
    # attribute. A decimal is only a number, and `hourly_rate` and `commission_rate`
    # are not the same kind of one. Read by the show page and by the form alike.
    def recourse_formats = {}

    # Columns holding a counter cache, each mapped to the association it counts. Read
    # from the `belongs_to` on the other side, which is where `counter_cache` is
    # declared: a column merely named `quote_count` is not one of these.
    def recourse_counters
      reflect_on_all_associations(:has_many).filter_map do |association|
        column = association.inverse_of&.counter_cache_column
        [column, association] if column
      end.to_h
    end

    # `ZIP code`: what to call a foreign key pointing here. A form's label, a table's
    # heading and a search prompt all name the same thing, so they name it once.
    def recourse_reference_name
      attribute = Recourse.downcase human_attribute_name(recourse_label)

      I18n.t 'recourse.reference', model: model_name.human, attribute: attribute
    end

    # True when the label has a length, so it is short enough to be typed and a
    # form can ask for the value instead of listing every record to pick from.
    def recourse_typed_label?
      validators_on(recourse_label).any? ActiveModel::Validations::LengthValidator
    end

    # Associations the index eager-loads, in any shape `includes` accepts. Every
    # belongs_to by default, since each cell naming one would be a query of its own.
    def recourse_includes = reflect_on_all_associations(:belongs_to).map(&:name)

    # How the index sorts its rows, in any shape `order` accepts. By id by default,
    # which is the one column every table has and the order rows were created in.
    def recourse_order = :id
  end
end

ActiveSupport.on_load :active_record do
  extend Recourse::Recoursive
end
