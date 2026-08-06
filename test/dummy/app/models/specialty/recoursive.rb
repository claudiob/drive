class Specialty
  # How a specialty is drawn.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_icon = { bootstrap: :award, ios: :'medal.fill', android: :workspace_premium }
    end
  end
end
