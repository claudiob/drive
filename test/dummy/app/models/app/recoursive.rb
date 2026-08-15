class App
  # The same as a setting: an app is configured over time, and the last change
  # is the one worth showing.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      # One name standing for the list: the webhook is wiring, not reading matter.
      def recourse_hidden = :webhook_url

      def recourse_timestamps = %i[updated_at]
    end
  end
end
