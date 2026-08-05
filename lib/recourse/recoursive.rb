require 'active_support'

module Recourse
  # Extends every Active Record model, so each one can say how it is labelled.
  module Recoursive
    # Column a combobox shows for a record, and selects alongside its id.
    def recourse_label = :name
  end
end

ActiveSupport.on_load :active_record do
  extend Recourse::Recoursive
end
