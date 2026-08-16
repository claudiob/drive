module Recourse
  # Resolves a submitted foreign key back to an id, for a belongs_to whose label
  # is typed rather than picked from a menu.
  module ReferenceResolution
  private

    # A foreign key whose label is typed arrives as that label, so it is looked up
    # here. Nothing found leaves the key nil, and `belongs_to` reports it missing.
    def resolve_references(attributes)
      resource_class.recourse_references.each do |association|
        key = association.foreign_key.to_s
        next unless attributes.key?(key) && association.klass.recourse_typed_reference?

        attributes[key] = reference_id association, attributes[key]
      end

      attributes
    end

    def reference_id(association, label)
      association.klass.find_by(association.klass.recourse_label => label)&.id
    end
  end
end
