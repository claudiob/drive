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
end
