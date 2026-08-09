class App
  # The same as a setting: an app is configured over time, and the last change
  # is the one worth showing.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_timestamps = %i[updated_at]
    end
  end
end
