class ZIP
  # Labels a ZIP by its code, since a ZIP has no name to show.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :code
    end
  end
end
