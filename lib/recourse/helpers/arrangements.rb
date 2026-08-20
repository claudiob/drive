module Recourse
  module Helpers
    # What a table somebody arranged by hand draws, and what it stops drawing.
    module Arrangements
    private

      # Whether these rows are ones a reader arranges — the question the controller
      # asked to build the relation, spelled again with what a view has to hand. Both
      # go through `Recourse.arranges?`, so the level rule is written once.
      def arranged?
        resource_model.respond_to?(:recourse_order) &&
          Recourse.arranges?(resource_model, resource_parent)
      end
    end
  end
end
