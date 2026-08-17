module Admin
  module Places
    # The other half of a bare action: the gem drew the button, and where a delete
    # goes afterwards is the host's to say. A memo is about a place polymorphically,
    # which is why a place can forget one without the routes carrying its id.
    class MemosController < RecoursesController
      def destroy
        place = Place.find params.expect(:place_id)
        Memo.where(about: place).destroy_all
        redirect_to place_path(place), status: :see_other
      end
    end
  end
end
