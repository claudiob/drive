Rails.application.routes.draw do
  # Deliberately not alphabetical: the sidebar follows this order, not a sort. Each
  # draws a different slice of the seven, so the pages a resource offers — and the
  # links the gem draws to them — are covered between them.
  namespace :admin do
    recourses :bookings, only: %i[index show destroy]
    recourses :providers
    recourses :franchises, except: :show
    recourses :zips, only: %i[index edit]
    recourses :markets, except: :show
    recourses :counties, only: :index
    recourses :specialties, except: :show
    recourses :settings, only: %i[index edit update]
    recourses :sources, except: :show
    recourses :contacts, except: :show
    recourses :agents, only: %i[index show]
    recourses :apps, only: %i[index edit update]
  end

  # The dummy app's own, which the twelve above came from fountain to sit beside.
  recourses :states, only: :index
  recourses :locations, only: %i[index new create]
  recourses :jobs
  recourses :messages

  # No index action, so no sidebar link.
  recourses :placeholders, only: []
end
