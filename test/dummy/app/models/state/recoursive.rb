class State
  # How a state is drawn.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_icon = { bootstrap: :geo, ios: :map, android: :map }
    end
  end
end
