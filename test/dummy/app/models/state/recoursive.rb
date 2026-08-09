class State
  # Census data, written once by the migration that created it, so every row carries
  # the same two timestamps and a table is better off without the columns.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_timestamped? = false
    end
  end
end
