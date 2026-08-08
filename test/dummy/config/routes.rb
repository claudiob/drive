Rails.application.routes.draw do
  # Deliberately not alphabetical: the sidebar follows this order, not a sort.
  recourses :bookings
  recourses :providers
  recourses :franchises
  recourses :zips, only: :index
  recourses :markets, only: %i[index new create edit update]
  recourses :counties, only: :index
  recourses :specialties
  recourses :settings
  recourses :sources, only: :index
  recourses :contacts
  recourses :agents, only: %i[index new create]
  recourses :apps

  # The dummy app's own, which the twelve above came from fountain to sit beside.
  recourses :states, only: :index
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
