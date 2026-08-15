class Setting
  # Labels a setting by its key, since a setting has no name to show.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      # A concept no icon set has heard of, which is what leaves this resource's
      # crumbs and tabs with no picture rather than Unicon's fallback circle.
      def recourse_icon = :configuration_knob

      def recourse_label = :key

      def recourse_timestamps = %i[updated_at]

      # A toggle flips too often to be worth refreshing every open screen for.
      def recourse_broadcasts? = false
    end
  end
end
