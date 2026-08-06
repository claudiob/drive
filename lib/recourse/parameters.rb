require 'active_support'

module Recourse
  # Turns what a form submitted into attributes a model will accept. Only foreign keys
  # need the translation: a reference whose label is typed rather than picked arrives
  # as that label, and has to be looked up before it can be assigned.
  module Parameters
    extend ActiveSupport::Concern

  private

    def resolve_references(attributes)
      resource_class.reflect_on_all_associations(:belongs_to).each do |association|
        key = association.foreign_key.to_s
        next unless attributes.key?(key) && association.klass.recourse_typed_label?

        attributes[key] = reference_id association, attributes[key]
      end

      attributes
    end

    def reference_id(association, label)
      association.klass.find_by(association.klass.recourse_label => label)&.id
    end
  end
end
