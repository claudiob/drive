class Home
  # How a home is drawn.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_icon = { bootstrap: :house, ios: :'house.fill', android: :home }
    end
  end
end
