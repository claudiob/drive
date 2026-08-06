require 'active_support'

module Recourse
  # Extends every Active Record model, so each one can say how it is labelled and drawn.
  module Recoursive
    # Drawn by anything that has not said otherwise. Every set has a plain circle.
    ICON = :circle

    # Column a combobox shows for a record, and selects alongside its id.
    def recourse_label = :name

    # What this resource is drawn with. A symbol where every icon set calls it the same
    # thing; a hash keyed `:android`, `:bootstrap` and `:ios` where they disagree.
    def recourse_icon = ICON

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
