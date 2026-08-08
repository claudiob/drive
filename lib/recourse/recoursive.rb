require 'active_support'

module Recourse
  # Extends every Active Record model, so each one says how it is labelled, what
  # its index eager-loads and how that index is sorted.
  module Recoursive
    # Column a combobox shows for a record, and selects alongside its id.
    def recourse_label = :name

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
