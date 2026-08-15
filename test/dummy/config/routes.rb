Rails.application.routes.draw do
  # Deliberately not alphabetical: the sidebar follows this order, not a sort. Each
  # draws a different slice of the seven, so the pages a resource offers — and the
  # links the gem draws to them — are covered between them.
  #
  # `scope module:` rather than `namespace`: the controllers live under `Admin::`,
  # while the paths stay where a reader expects them — `/contacts`, not
  # `/admin/contacts`.
  scope module: :admin do
    recourses :bookings, only: %i[index show destroy]
    recourses :providers
    recourses :franchises, except: :show
    recourses :zips, only: %i[index edit] do
      # `create` with no `new`: the navbar offers the one-click Create button in
      # the Add link's place, on our word that a bare location can stand.
      recourses :locations, only: %i[index create]
    end
    recourses :markets, except: :show
    recourses :counties, only: %i[index show] do
      # Nested: reached through a county's ZIPs count, not from the sidebar, and
      # bare on purpose — index, new and create are the nested default.
      recourses :zips
    end
    recourses :specialties, except: :show
    recourses :settings, only: %i[index edit update]
    recourses :sources, except: :show do
      # Nested: what proves the parent's own filter leaves the search form.
      recourses :contacts, only: :index
    end
    recourses :contacts, except: :show
    recourses :agents, only: %i[index show] do
      # Nested with no counter cache behind it: the card tab reads bare `Settings`.
      recourses :settings, only: :index
    end
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
