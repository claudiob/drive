class County
  # Census data, like the states above it and the ZIPs below: written once, so its
  # timestamps say nothing a reader of the table needs.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_timestamped? = false
    end
  end
end
