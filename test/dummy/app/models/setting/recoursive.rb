class Setting
  # Labels a setting by its key, since a setting has no name to show.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :key
    end
  end
end
