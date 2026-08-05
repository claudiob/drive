Rails.application.routes.draw do
  # Deliberately not alphabetical: the sidebar follows this order, not a sort.
  recourses :contacts
  recourses :states, only: :index
  recourses :counties, only: %i[index new create]
  recourses :echoes, only: :index
  recourses :markets, only: %i[index new]
  recourses :zips, only: :index
  recourses :sources, only: %i[index new]
  recourses :agents, only: %i[index new]

  # No index action, so no sidebar link.
  recourses :placeholders, only: :new
end
