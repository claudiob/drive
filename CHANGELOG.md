# Changelog

All notable changes to this project will be documented in this file.

For more information about changelogs, check [Keep a Changelog](http://keepachangelog.com) and
[Vandamme](http://tech-angels.github.io/vandamme).

## Unreleased

* A search box no longer names a label Ransack will refuse

  A foreign key whose model is too long to list is searched through rather than
  filtered by, under the far model's label — `location_street` for the ZIP a booking
  is at. Whether that label could be searched at all was asked of its type, and
  encryption leaves a type alone: an encrypted `street` reads as a word here, so the
  box asked for `specialty_name_or_location_street_or_provider_name_cont` and Ransack
  answered with a `NoMethodError`. Every index reaching that model through a key
  raised — five of them, in the app this was found in — and only in an environment
  with enough rows to stop the key being a menu, so a test suite drew a filter where
  a browser drew a term and never saw it.

  The label has to be a column Ransack will answer to as well, which is the allowlist
  rather than the type. A model whose label the search cannot match is no longer
  reached through: its key stays a filter where it can be one, and the box looks
  through what is left.

  A host relying on the old behaviour was relying on a 500. One whose label is
  encrypted loses the ability to search through that key — name a plaintext column as
  the label to get it back.

* A singular nested `recourse` routed `show` earns a tab, not nothing

  `recourse :property` under a location is one record reached with no id of its own,
  and Rails' `resource` draws no index for it — so a nesting the gem only drew a tab
  for where an index was routed could never earn one. `recourse :lead, only: :show`
  was routed, served, and linked from nowhere at all; `only: %i[new create show]` was
  the same, the `new` route being enough to suppress the button a bare action would
  otherwise have earned.

  A nesting with no index and a `show` the router needs no id for now earns a tab on
  the record it hangs off — beside Show and Edit, in the order routes.rb nested it,
  pointing at `/locations/5/property`. It reads in the singular, since there is only
  ever one: `Property`, or `HouseCanary` where a locale renamed the model. That word
  comes from the same split and the same `Recourse.known_singular` the bare action's
  button takes it from, so a tab and a button under one record cannot come to
  disagree. No count, since a `has_one` has nothing to count, and no icon, since an
  icon on a tab comes from an association the gem counted and from nowhere else. An
  index still wins where a host drew both.

  A page nested under a record now sits in that record's card whichever page it is.
  `show` and `edit` were handing the card their own record while the tabs above it
  were built from the parent's path, so a nested `/posts/1/ratings/2` drew a Show tab
  pointing at `/posts/2`. Nothing linked to such a page before, which is why nobody
  saw it; a singular resource's tab is the first thing that does.

  Any host with a singular nested `recourse` routing `show` will see a new tab on
  every one of that parent's records — the ones whose `has_one` is nil included. A
  singular resource has no id to look up, so what the page reads out was always the
  host's to find, and now something links to the page it finds nothing for. The chrome
  holds: a record the host did not assign leaves the crumb above it unnamed rather
  than raising, where `resource_record_label` used to read `attributes` off the nil.
  What the body says about the absence is the host's to write — or the host redirects,
  the way one asking a service for an answer it has not fetched yet already does.

* A JSON column stays off an index table

  A `json` or `jsonb` column used to reach a table, where the gem has no arm for one —
  so the Hash was stringified into a cell and one payload made the row wider than the
  page. It now joins what a table leaves off by default, beside ciphertext, the
  primary key and the timestamps: a payload is a service's answer kept whole, not
  something the row is about. `def recourse_displayed = :property_details` puts it
  back for a host that wants it, and the record's own page reads it out either way.

  Search and sorting are unaffected — `json` was never a searchable type.

* A bare action's button is named for the route it is, namespace and all

  A nested resource routed `create` with no `index` gets a button on its parent's
  card, and that button took its word from the last segment of the path — so
  `namespace(:quick) { recourses :memos, only: :create }` under a person read
  `Add memo`, exactly like the `memos` index beside it, and the two posted different
  records to different controllers. It now reads `Add quick memo`. The namespace is
  the only thing telling two routes to the same model apart, and the tab for a
  nested index already read that way; both now come from one split.

  Any host with a namespaced bare action will see its button's wording change.

* A counter's cells say what they count, without drawing anything

  A counter cache's heading names the counted model and its cells hold the bare
  figure, which stops helping the moment the heading scrolls off the top — and a
  link whose whole text is `38,405` announces as `38,405` and nothing else. Each
  cell now carries a tooltip reading the model's plural and an `aria-label` reading
  `38,405 ZIPs`. An unlinked count is a `<span>` carrying the same pair, so it is
  named like a linked one.

* The scheme toggle holds the foot of the viewport

  At the foot of a sidebar as tall as the table it sat below the fold on any long
  index, which is where it is least use. It is now `position: sticky`, so it holds the
  bottom of the window while the content beside it scrolls and comes to rest in its
  real place at the end — sticky rather than fixed, so it keeps the sidebar's column
  and can never land over the table.

* `:bootstrap` joins `Recourse::THEMES`, so the toggle can rotate back to it

  Bootstrap's own palette was reachable only by not setting one, which meant a reader
  who clicked the sidebar's toggle could never get the pages' original look back. It is
  now a palette like the other eight, whose stylesheet declares nothing: the eight work
  by overriding upstream's `:root`, so dropping their block is all it takes. The default
  is still nil, so a host that names no palette still links no stylesheet at all.

  `THEMES` is now a name mapped straight to its dark-label families rather than to a
  hash. The `primary:` key it used to carry had no reader left after each palette began
  declaring its own `--bs-primary-*`, and dead data that can drift from the stylesheet
  is worse than none.

* A kept row is tinted, and the tint is what reports the click

  A table whose model keeps bookmarks now paints the whole `<tr>` of a row the viewer
  has kept — a twelfth of the primary mixed into the page, so it follows every palette
  and both colour modes. Twenty rows are scanned by it long before anybody reads a
  column of icons. It is a background rather than Bootstrap's `.table-active`, which
  sets the same variable `.table-hover` does and would leave a kept row looking like
  the row under the cursor.

  The square's success toast is gone with it. The icon still flips on the click, but
  the row takes colour only when the write comes back, so the confirmation lands where
  the click happened instead of in a corner of the page — and a column built to be
  clicked twenty times no longer answers with twenty toasts. Only a failure speaks
  now. The no-JavaScript path still flashes `Bookmark added` and `Bookmark removed`,
  since it reloads the page and would otherwise say nothing.

  `data-bookmark-messages-value` is now `data-bookmark-error-value`, a string rather
  than JSON, which matters to a host that had overridden the square.

* [BREAKING CHANGE] `recourse_timestamps` is gone; `recourse_displayed` asks

  A model that showed `created_at` or `updated_at` on its table said
  `def recourse_timestamps = %i[created_at updated_at]`. It now says
  `def recourse_displayed = %i[created_at updated_at]`, which is the hook that
  already named back every other column a table leaves off — the encrypted ones, the
  primary key, a polymorphic `*_type`, the inheritance column. Two hooks meaning
  "draw this anyway" were one too many, and unlike the old one this accepts a single
  symbol as readily as a list.

  The timestamps still come last, and still `created_at` before `updated_at` whatever
  order they are named in. Nothing else moves: the show page reads both out for every
  model as before, forms still never offer them, and every heading a table shows can
  still be sorted by.

* `Recourse.theme` draws every page in a code-editor colour scheme

  Eight of them — `dawn`, `dracula`, `gruvbox`, `monokai`, `nord`, `one_dark`,
  `solarized` and `tokyo_night` — set from an initializer with one line. Bootstrap
  derives every surface, border and text colour from one neutral ramp and names each
  of its meanings after a family, so repainting the ramps carries a scheme to the page
  itself rather than only to its accents. Each is a stylesheet the engine serves at
  `/recourse/themes/<name>.css`, and each fills both arms of every ramp, so a page
  still follows the reader's system setting. `Recourse.color` composes with it: the
  scheme repaints the ramps, the colour says which repainted ramp is primary.

* The sidebar ends with a moon or a sun, and a reader picks their own palette

  A click moves the page to another of the eight and into the other mode — a moon
  while it is light, a sun while it is dark — so the schemes are reachable from the
  page rather than only from an initializer. The next palette is random among those
  not showing. The choice is kept in the reader's browser under
  `localStorage['recourse-scheme']` and put back before the first paint by an inline
  script in the head, and again by the controller on `connect`, since Turbo merges the
  head on a visit. The mode is forced with Bootstrap's own `data-bs-theme`, so until a
  reader clicks the page still follows their system setting.

  Each palette now declares the nine `--bs-primary-*` itself, from the family it leads
  with, so the primary travels when the stylesheet is swapped. `Recourse.color` still
  wins where a host names one. `Recourse.primary_color`, added earlier in this release,
  is gone with it — the palette answers that now.

* `--bs-primary-contrast` follows the family instead of always being white

  The label on a solid button is now `var(--bs-white)` or `var(--bs-gray-975)`,
  whichever reads better on the step the button is filled with — upstream's own shape,
  since Bootstrap gives `warning` and `info` a dark label for the same reason. This
  fixes `Recourse.color = :orange`, where white on `orange-500` was 2.90:1, under the
  3:1 WCAG asks of a UI component. `blue`, `brown` and `gray` gain a dark label too.
  `_color.html.erb` takes the ink as a second local, so a host overriding that partial
  should expect it.

## 4.0.0 - 2026-08-15

Version 4 is a rewrite, developed under the working name `drive` and released here
because it is the same library: the module is still `Recourse` and the entry point is
still one word in `config/routes.rb`.

Version 3 drew the routes and served one screen — a paginated, searchable index — and
left the controller, the other six actions and every form to the host app. Version 4
serves all seven, defines the controllers itself, and works out what each screen should
look like by reading the model: its validators, its associations, its column types and
its indexes. Most of what a host used to override is now something it no longer writes.

* [BREAKING CHANGE] Rails 8.1 and Ruby 3.2 are the minimum
* [BREAKING CHANGE] `recourses` defines the controller as well as the routes

  A host no longer writes `class PostsController < RecoursesController` for each
  resource. The controller is defined as the route is drawn, and a host that wants one
  of its own still writes it — the gem only fills the gap. `RecoursesController`
  changes meaning with that: it is no longer the class each resource subclasses but the
  one they all inherit, and a host defines it — `class RecoursesController <
  Recourse::BaseController` — to put a `before_action` above every screen at once.

* [BREAKING CHANGE] `search_field` and `search_prompt` are no longer yours to define

  They are derived now, and written down in the README so you can see what a page will
  do rather than so a model can answer differently. A search box looks through every
  indexed string column the table shows, plus the label behind a foreign key too long
  to list, and says so in its own placeholder. `searchable_fields` is gone outright.

* [BREAKING CHANGE] The Ransack hooks default to something instead of to nothing

  `ransackable_attributes`, `ransackable_associations`, `ransortable_attributes` and
  `filter_fields` are still yours to override, but a model that says nothing is now
  fully searchable, sortable and filterable rather than not at all: a column is
  sortable when an index covers it — the only signal a schema gives about which
  columns identify a row rather than describe it — an enum earns a filter, and so
  does each `belongs_to`. A host that listed columns by hand can delete those methods.

* [BREAKING CHANGE] A `filter_fields` entry changed shape

  It is keyed by the predicate and carries its options:
  `{ 'state_id_in' => { label: 'Home state' } }`.

* [BREAKING CHANGE] `recourse_searchable?`, `recourse_sortable?` and `recourse_cachable?`
  are gone

  The first two follow from the indexes. Caching is no longer a per-model switch: the
  table is a fragment keyed on the relation, so it expires when a row changes and needs
  nobody to remember to turn it off.

* [BREAKING CHANGE] `Recourse.resources` and `navigation_links` are gone

  The gem draws its own sidebar from the resources `recourses` declared, so a host no
  longer builds a navbar out of that hash. `NavigableHelper` and its
  `NAVIGATION_ICONS` table went with it: an icon now comes from the `unicon` gem,
  named by `recourse_icon`, which defaults to the model's own name.

* [BREAKING CHANGE] `search_highlight` takes the column, not the model

  `search_highlight(post.content, model: Post)` becomes
  `search_highlight(post.content, :content)`. Only a column the search actually looked
  through is marked, so a highlight can no longer claim a match that never happened.

* [BREAKING CHANGE] A row partial sorts with `sort_header`, not Ransack's `sort_link`
* [BREAKING CHANGE] Pagy 43 and Ransack 4.4 are the minimum
* [Feature] Every action is served: index, show, new, create, edit, update and destroy
* [Feature] A form field is chosen to suit each column, and carries the rules the
  model's validators state — a length becomes a `maxlength`, a format becomes a
  `pattern`, a numericality becomes a numeric keyboard
* [Feature] An enum becomes a badge on a page and a menu in a form; a foreign key
  becomes a menu of the records it points at, or a field to type into where there are
  too many to list
* [Feature] Values are formatted by what the column holds: delimited integers, decimals
  at their own scale, phone numbers, times in a `time` tag, links for a URL
* [Feature] Nested resources are drawn as tabs on the parent's card, counted where a
  counter cache exists
* [Feature] Active Record Encryption is respected throughout: an encrypted column never
  reaches a table, arrives masked on a record's own page behind a `Show`, and is offered
  in the clear on the form that edits it
* [Feature] Turbo drives the screens — frames, morph refreshes, and a delete that names
  what is about to go with it before it goes
* [Feature] Bootstrap 6 and Bootstrap Icons are vendored and served by the engine, so a
  host with no asset pipeline and no CDN still gets styled screens
* [Feature] Three generators: `rails g recourse` writes a model, its migration, its
  route and its seeds; `rails g recourse:counters` writes both sides of an association;
  `rails g recourse:seed` writes varied rows for every resource drawn
* [Feature] `Recourse.color = :purple` restyles every screen at once
* [Feature] Model hooks for the rest: `recourse_label`, `recourse_hidden`,
  `recourse_timestamps`, `recourse_order`, `recourse_icon`, `recourse_includes` and
  `recourse_broadcasts?`
* [Feature] Every string the gem shows is a key in `config/locales/recourse.en.yml`

## 3.0.3 - 2026-07-24

* [Feature] Add "Agents" icon

## 3.0.2 - 2026-07-23

* [Feature] Add "Contacts" icon

## 3.0.1 - 2026-07-22

* [Feature] Add searchable_fields to models

## 3.0.0 - 2026-07-22

* [BREAKING CHANGE] Replace single filter_field with multiple filter_fields

## 2.0.2 - 2026-07-20

* [Feature] Add "Contract", "Profile", "CRM" icons

## 2.0.1 - 2026-07-13

* [Fix] Improve search bar responsiveness

## 2.0.0 - 2026-07-13

* [BREAKING CHANGE] Restyle table and search field to take advantage of Bootstrap 6

## 1.4.6 - 2026-07-10

* [Feature] Replace "Benches" with "Markets" icons

## 1.4.5 - 2026-06-24

* [Feature] Add "Benches" icons

## 1.4.4 - 2026-06-24

* [Feature] Add "Platforms" icons

## 1.4.3 - 2026-06-24

* [Feature] Add "Brands" icons

## 1.4.2 - 2026-06-24

* [Feature] Add common recourse icons
* [Feature] Add common acronyms, e.g.: API, CRM, ZIP

## 1.4.1 - 2026-06-23

* [Fix] Remove deprecated LookupContext.find_template!

## 1.4.0 - 2026-06-23

* [Feature] Add navigation_links method

## 1.3.5 - 2026-05-15

* [Feature] Display pagy info with number delimiters

## 1.3.3 - 2026-04-09

* [Fix] Allow for nested resources not defined at the root level

## 1.3.2 - 2026-04-09

* Temporarily disable caching

## 1.3.1 - 2026-04-06

* [Fix] Use a different caching key based on the controller path

Posts could be displayed differently under /users/:id/posts or under /topics/:id/posts
so they should be cached separately.

## 1.3.0 - 2026-04-03

* [BREAKING CHANGE] Rename `search_placeholder` to `search_prompt`

## 1.2.0 - 2026-03-31

* [BREAKING CHANGE] `RecourseController` is now `RecoursesController`
* [BREAKING CHANGE] "Add" button is now yield in the `content_for :actions`
* [BREAKING CHANGE] `recourse_positionable?` is no longer supported
* [Deprecation] `header:` parameter is no longer required in `column`.
* [Feature] support for nested resources
* [Feature] support for ransack searches

## 1.1.0 - 2026-03-24

* [BREAKING CHANGE] `recourses` only accepts one resource if a block is provided
* [BREAKING CHANGE] `recourses` automatically sets the module for nested resources

Before this change this config/routes.rb was valid:

```ruby
recourses(:users, :posts) { resources :comments }
```

and followed Rails `resources` behavior of creating **two** nested resources: `users/comments` and
`posts/comments`. After this change, each base resource needs to be defined separately:

```ruby
recourses(:users) { resources :comments }
recourses(:posts) { resources :comments }
```

This syntax is more explicit and allows nested resources to be defined under the parent's module.
In other words, the previous code is equivalent to:

```ruby
resources(:users) { resources :comments, module: :users }
resources(:posts) { resources :comments, module: :posts }
```

which allows developers to have two different controllers/actions to display a user comments
(/users/:id/comments) or to display a post comments (/posts/:id/comments)

## 1.0.2 - 2026-03-23

* [BUG] Avoid Zeitweirk conflict when loading Active Record

## 1.0.1 - 2026-03-10

* [BUG] Only show search form when search attributes are present

## 1.0.0 - 2026-03-10

* [FEATURE] New `recourses` method that can be invoked inside config/routes.rb

`recourses` is like `resources` on steroids for admin-only routes:

- All the routes are included in `Recourse.resources` to easily display in a navbar
- Their controllers do not need to define the `index` action: they inherit a predefined one
- There is also a predefined `index.html` view which displays the resources paginated/searchable.
- The content of each row can be customized defining a new `_row.html.erb` partial


