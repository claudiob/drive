Rails.application.routes.draw do
  # Deliberately not alphabetical: the sidebar follows this order, not a sort. Each
  # line draws a different slice of the seven, so the pages a resource offers — and
  # the links the gem draws to them — are covered between them.
  #
  # `scope module:` rather than `namespace`: the controllers live under `Admin::`
  # while the paths stay where a reader expects them — `/places`, not
  # `/admin/places`.
  scope module: :admin do
    # All seven, and the model that has a column of every kind.
    recourses :places do
      # `recourse` rather than `recourses`: one memo about this place, reached with
      # no id of its own. Routed `destroy` alone, so it is an action rather than a
      # page, and its button sits on the place.
      recourse :memo, only: :destroy
      # A name this app has no class for at all: an action is a verb, and the button
      # still needs a word.
      recourse :sweep, only: :create
      # And one routed `show`: a page rather than an action, which Rails draws no
      # index for -- so the tab on the place is the only thing that reaches it.
      recourse :zip, only: :show
      # The same, and this one the gem serves whole: a `has_one` it reads off the
      # place, with `new` routed so an absent one is a form to fill in rather than a
      # page saying there is none.
      recourse :audit, only: %i[new create show]
      # The same, over a record a place may not have: what the host finds is what the
      # page reads, and a page that finds nothing says so.
      recourse :person, only: :show
      # No `Photo` in this app: the name is what the place has attached, and the
      # table is of Active Storage's blobs.
      recourses :photos, only: :index
    end

    # Everything but making one: a person arrives from somewhere else.
    recourses :people, except: %i[new create] do
      # A counted tab on the person's card, since places carry a counter cache.
      recourses :places, only: :index
      # And an uncounted one. `create` with no `new`: the navbar offers the
      # one-click Create button in the Add link's place, on our word that a bare
      # memo can stand.
      recourses :memos, only: %i[index create]
      # Every team, with the membership to add or drop beside each one — a listing
      # of the far side of a many-to-many rather than of the rows already joined,
      # which is what `through:` says and what the buttons in it write.
      recourses :teams, only: :index, through: :memberships
      # An action rather than a page: `create` with no index to reach it from, so
      # its button sits on the person instead, beside the breadcrumbs. The gem draws
      # the button; where a bare action goes afterwards is the host's to say, which
      # is why this one has a controller of its own.
      namespace(:quick) { recourses :memos, only: :create }
    end

    recourses :teams, except: :show do
      # A plain `resource`, so the gem records nothing and offers no button: the
      # wording counts what a sweep would clear, which is the host's to say.
      resource :sweep, only: :create
      # A `namespace` between a block and what it nests: the routes and the
      # controller come out under it, and no tab is drawn for a child filed there.
      namespace(:visited) { recourses :places, only: :index }
      # A nested index the parent has no `has_many` for, which a host draws over an
      # aggregate, an attachment, or the whole of a table read under one record. The
      # tab is named after the route, since there is no association to count or to
      # take an icon from.
      recourses :memos, only: :index
    end

    # Edited but never shown, and the table a foreign key is typed to reach.
    recourses :zips, only: %i[index edit update] do
      # No `only:` and no `except:`, so a nested resource takes the collection
      # actions by default: list the parent's rows, and add one.
      recourses :places
    end
  end

  # Outside the module, and with an index template of the host's own.
  recourses :memos, except: :show

  # No index action, so no sidebar link and nothing for the gem to draw.
  recourses :placeholders, only: []
end
