module Admin
  module Places
    # A verb with no model behind it, which is what most bare actions are.
    class SweepsController < RecoursesController
      def create
        redirect_to place_path(Place.find(params.expect(:place_id))), status: :see_other
      end
    end
  end
end
