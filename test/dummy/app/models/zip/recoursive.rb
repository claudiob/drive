class ZIP
  # Labels a ZIP by its code, since a ZIP has no name to show, and lists them in
  # that order rather than the order they were made.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :code

      def recourse_order = :code
    end
  end
end
