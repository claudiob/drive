module Admin
  module People
    module Quick
      # What a bare action does, which is never the gem's to say: it starts something
      # and goes back to the page that asked. The gem drew the button.
      class MemosController < RecoursesController
        def create
          person = Person.find params.expect(:person_id)
          person.memos.create! body: 'Noted'
          redirect_to person_memos_path(person), status: :see_other
        end
      end
    end
  end
end
