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
  recourses :jobs
  recourses :messages

  # No index action, so no sidebar link.
  recourses :placeholders, only: []

  # Namespaced, and the app defines no `Admin` module of its own: the controller
  # `Admin::SourcesController` is the gem's to make.
  namespace :admin do
    recourses :sources, only: :index
  end
end
