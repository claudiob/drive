class Agent
  # Labels an agent by their email, which is all an agent is known by.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :email
    end
  end
end
