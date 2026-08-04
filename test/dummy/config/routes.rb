Rails.application.routes.draw do
  recourses :contacts, only: :index
  recourses :counties, only: :index
  recourses :echoes, only: :index
  recourses :states, only: :index
end
