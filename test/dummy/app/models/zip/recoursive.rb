class ZIP
  # Labels a ZIP by its code, since a ZIP has no name to show, and lists ZIPs in
  # that order — 40,965 rows sorted by id is nobody's idea of a first page.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :code

      def recourse_order = :code

      def recourse_timestamped = false
    end
  end
end
