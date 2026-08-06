Rails.application.routes.draw do
  # Deliberately not alphabetical: the sidebar follows this order, not a sort.
  recourses :contacts do
    # Toggling a conversation read is a nested resource, not an action on contacts.
    resource :read, module: :contacts, only: %i[create destroy]
    resources :messages, module: :contacts, only: :index
  end
  recourses :states, only: :index
  recourses :counties, only: :index
  recourses :echoes, only: :index
  recourses :markets, only: %i[index new create edit update]
  recourses :zips, only: :index
  recourses :sources, only: :index
  recourses :agents, only: %i[index new create]
  recourses :locations, only: %i[index new create]
  recourses :jobs
  recourses :specialties
  recourses :messages

  # Native-only screens, so plain routes rather than recourses: neither is a model,
  # and neither belongs in the desktop sidebar.
  resources :lists, only: :index
  resources :places, only: :index
  resources :badges, only: :index
  resource :settings, only: :show, controller: :settings

  # No index action, so no sidebar link.
  recourses :placeholders, only: []
end
