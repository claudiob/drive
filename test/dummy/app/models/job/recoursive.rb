class Job
  # Labels a job by its title, since a job has no name to show, and draws it as a hammer.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :title

      def recourse_icon = { bootstrap: :hammer, ios: :'hammer.fill', android: :build }
    end
  end
end
