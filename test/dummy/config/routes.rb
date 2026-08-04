Rails.application.routes.draw do
  recourses :contacts, only: :index
  recourses :echoes, only: :index
end
