class Market
  # How a market is drawn.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_icon = { bootstrap: :'pin-map', ios: :'mappin.circle', android: :place }
    end
  end
end
