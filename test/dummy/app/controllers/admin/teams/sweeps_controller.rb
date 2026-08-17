module Admin
  module Teams
    # A plain `resource`, so the gem records nothing about it and draws no button for
    # it: the wording counts the places a sweep would clear, which only this app can
    # say. `recourse_extra_actions` is where the button comes from instead.
    class SweepsController < RecoursesController
      def create
        redirect_to edit_team_path(Team.find(params.expect(:team_id))), status: :see_other
      end
    end
  end
end
