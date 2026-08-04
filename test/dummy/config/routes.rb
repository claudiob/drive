Rails.application.routes.draw do
  # Deliberately not alphabetical: the sidebar follows this order, not a sort.
  recourses :contacts, only: :index
  recourses :states, only: :index
  recourses :counties, only: %i[index new]
  recourses :echoes, only: :index
  recourses :markets, only: :index

  # No index action, so no sidebar link.
  recourses :placeholders, only: :new
end
