class County
  # How a county is drawn. One name serves every icon set.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_icon = :map
    end
  end
end
