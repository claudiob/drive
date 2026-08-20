module Admin
  module Places
    # The other half of a singular resource: the gem drew the tab, and which one record
    # the path names is the host's to find -- there is no id in it to look up.
    class ZipsController < RecoursesController
    private

      def find_resource
        assign @recourse_parent.zip
      end
    end
  end
end
