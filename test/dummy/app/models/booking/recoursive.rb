class Booking
  # Labels a booking by its summary, since a booking has no name to show.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :summary
    end
  end
end
