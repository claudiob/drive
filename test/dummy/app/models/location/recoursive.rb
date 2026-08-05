class Location
  # Labels a location by its city. There is no name, and the street is encrypted —
  # labelling by that would put it in every combobox that offers a location.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :city
    end
  end
end
