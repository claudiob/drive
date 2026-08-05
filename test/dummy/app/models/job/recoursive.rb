class Job
  # Labels a job by its title, since a job has no name to show.
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :title
    end
  end
end
