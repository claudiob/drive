require 'active_support'

module Recourse
  # Extends every Active Record model, so each one can say how it is labelled.
  module Recoursive
    # Column a combobox shows for a record, and selects alongside its id.
    def recourse_label = :name

    # True when the label has a length, so it is short enough to be typed and a
    # form can ask for the value instead of listing every record to pick from.
    def recourse_typed_label?
      validators_on(recourse_label).any? ActiveModel::Validations::LengthValidator
    end
  end
end

ActiveSupport.on_load :active_record do
  extend Recourse::Recoursive
end
