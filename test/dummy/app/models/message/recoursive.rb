class Message
  # How a message is drawn.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_icon = { bootstrap: :'chat-text', ios: :message, android: :message }
    end
  end
end
