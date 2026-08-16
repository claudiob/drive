class MSA
  # Extends MSA with what it is called by and the order its rows are read in.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      # A code rather than a name: what identifies one of these to somebody typing.
      def recourse_label = :code

      # And the order that code reads in, rather than the order they were made.
      def recourse_order = :code
    end
  end
end
