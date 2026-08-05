Rails.application.routes.draw do
  # Deliberately not alphabetical: the sidebar follows this order, not a sort.
  recourses :contacts
  recourses :states, only: :index
  recourses :counties, only: :index
  recourses :echoes, only: :index
  recourses :markets, only: %i[index new create edit update]
  recourses :zips, only: :index
  recourses :sources, only: :index
  recourses :agents, only: %i[index new create]
  recourses :locations, only: %i[index new create]

  # No index action, so no sidebar link.
  recourses :placeholders, only: []

  # Signing in and out. Its own name rather than fountain's `resource :agent, only:
  # :new`, because `recourses :agents` already draws a `new_agent` route for the form
  # that creates one — the sign-in page would have lost the name to it. Google is
  # configured with this exact URL as a redirect URI, so renaming it breaks sign-in.
  scope module: :unauthenticated do
    get 'sign_in', to: 'agents#new', as: :sign_in
  end

  resource :agent, only: [] do
    resource :session, module: :agents, only: :destroy
  end
end
