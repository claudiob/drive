class ZIP
  # Labels a ZIP by its code, since a ZIP has no name to show, and draws it as a pin.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :code

      def recourse_icon = { bootstrap: :'geo-alt-fill', ios: :mappin, android: :pin_drop }
    end
  end
end
