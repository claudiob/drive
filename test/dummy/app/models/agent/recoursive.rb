class Agent
  # How an agent is drawn.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_icon = { bootstrap: :robot, ios: :'person.badge.key', android: :support_agent }
    end
  end
end
