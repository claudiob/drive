class Source
  # How a source is drawn.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_icon = { bootstrap: :signpost, ios: :'signpost.right', android: :signpost }
    end
  end
end
