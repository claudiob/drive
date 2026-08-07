# Recourse

A `routes.rb` DSL that mounts ready-made resource screens.

Add one line to `config/routes.rb` and Recourse draws the routes and serves the
controller and views needed to browse and edit a resource. Nothing is written
into your app: every controller, template and partial it supplies is a default,
and defining your own takes precedence over it.

> **Status:** early development. `index`, `new`, `create`, `edit` and `update`
> work; `show`, `destroy` and the eject generator are not implemented yet.

## Requirements

- Ruby 3.2 or newer.
- Rails 8.1 or newer — `actionpack`, `activerecord` and `railties`.
- `pagy` 43.6 or newer, which paginates every index.

## Installation

The gem is called `drive`; the library it loads calls itself `Recourse`.

```ruby
gem 'drive'
```

Then run `bundle install`. There is nothing to mount and no initializer to
write: the engine adds the routing DSL, the model hooks and a file server for
its own CSS and JavaScript as the app boots.

## `recourses`

```ruby
# config/routes.rb
Rails.application.routes.draw do
  recourses :contacts
  recourses :markets, only: %i[index new create edit update]
  recourses :states, only: :index
  recourses :placeholders, only: []
end
```

`recourses` accepts everything `resources` accepts — `only:`, `except:`, a
block to nest in — and for each name it does three things:

1. Records the name in `Recourse.declared`, in the order `routes.rb` lists it.
   The sidebar follows that order, not an alphabetical one.
2. Defines `ContactsController` as a subclass of `RecoursesController`, unless
   the constant already resolves. A Zeitwerk autoload counts, so a file in
   `app/controllers` is enough to keep the gem from defining anything.
3. Draws the routes, by calling `resources` with the arguments it was given.

Because the third step is plain `resources`, `recourses :contacts` also routes
`show` and `destroy`, which no gem-supplied action answers yet. Pass `only:`
to draw the five that work, or write the missing actions yourself.

A resource with no `index` route gets no sidebar entry, which is what
`only: []` is for.

## The screens

| Action | What it answers |
| --- | --- |
| `index` | one page of the model — 20 rows, `?page=2` for the next |
| `new` | a blank record's form |
| `create` | the index again, or the form with the errors on it |
| `edit` | the form for the record the id names |
| `update` | the index again, or the form with the errors on it |

`index` reads the model's `recourse_includes` and `recourse_order`, so a table
cell naming a referenced record costs no query of its own. The table hides
every encrypted column, and a model with no rows renders `No contacts.`
instead.

`new` and `edit` assign the record twice: to `@recourse`, and to the name Rails
would use, so `@contact` is what a view of yours can read.

`create` and `update` permit every editable column, then take one of two
branches. Saved, they set `flash.notice` to `Contact was created.` and redirect
to the index with `303 See Other`; rejected, they set `flash.now.alert` and
re-render the form with `422 Unprocessable Entity`. `edit` and `update` look
their record up with `find`, so an id that names nothing raises
`ActiveRecord::RecordNotFound` and Rails answers `404`.

Two column lists decide what a screen shows, and they are deliberately not the
same one:

- A table shows every column except the encrypted ones, so a column holding PII
  never reaches an index page.
- A form offers, and `create` permits, `Recourse.editable_columns` — every
  column except `id`, `created_at` and `updated_at`. Encrypted columns are
  offered, as password fields.

A cell renders by what the column holds: a `belongs_to`'s foreign key as the
label of the record it points at, a time as `Aug 4 at 03:47pm EDT`, an array as
its values joined by commas, a `phone` through `number_to_phone`.

## What a model can say

Every Active Record model answers four class methods: the engine extends
`ActiveRecord::Base` with `Recourse::Recoursive` on load, so the defaults are
there without a model mentioning them.

| Method | Default | What it decides |
| --- | --- | --- |
| `recourse_label` | `:name` | the column that stands for a record — what a combobox lists, and what a table cell shows for a foreign key pointing here |
| `recourse_typed_label?` | true when that column has a length validator | whether a foreign key to this model is typed into a text field or picked from a list |
| `recourse_includes` | every `belongs_to` the table names | what the index eager-loads, in any shape `includes` accepts |
| `recourse_order` | `:id` | how the index sorts, in any shape `order` accepts |

Overriding one means overriding a class method, which is what the `Recoursive`
concern next to the model is for:

```ruby
# app/models/zip/recoursive.rb
class ZIP
  module Recoursive
    extend ActiveSupport::Concern

    class_methods do
      def recourse_label = :code

      def recourse_order = :code
    end
  end
end
```

```ruby
# app/models/zip.rb
class ZIP < ApplicationRecord
  include Recoursive
end
```

`recourse_label` has to name a real column rather than a method, since it is
`select`ed alongside the id. Pick an encrypted column and its plaintext is what
the label reads — on every page that references the model, not just the form.

## What a field becomes

`recourse_typed_label?` is what splits the two kinds of foreign key. A label
with a length validator is bounded, so it can be typed; the field asks for the
label under the foreign key's own name and the controller looks the record up
on the way in — `ZIP.find_by code: '90210'` — so no model needs a virtual
attribute and no strong parameter needs a special case.

| Column | Field |
| --- | --- |
| a foreign key whose target's label is typed | text field, resolved to an id on submit |
| any other foreign key | a searchable combobox of every record, by label |
| an encrypted attribute | password field |
| `email`, `color` | email field, color field |
| a `date`, `time` or `datetime` attribute | date, time or `datetime-local` field |
| anything else | text field |

The type comes from the model's own `type_for_attribute`, so an `attribute
:opens_on, :date` override counts.

What the browser then enforces is read from the validators, never from the
schema: `maxlength` and `minlength` from a length validator, `pattern` from a
format validator's regexp with its anchors removed, `required` from a presence
validator on the column or on the association, a numeric `inputmode` where the
pattern admits only digits. A field with a pattern also gets a `title` naming a
value that would match, and an optional field gets `Optional` as its
placeholder. A constraint your database has and your model does not is a
constraint no field can show.

## Overriding a screen

Anything your app defines wins, because your app's view paths come first and
`define_missing` steps aside for a controller that already exists.

| Define this | To replace |
| --- | --- |
| `app/controllers/contacts_controller.rb` | the whole controller |
| `app/views/contacts/index.html.erb` | the index template — `new` and `edit` the same way |
| `app/views/contacts/_row.html.erb` | the cells of one row |
| `app/views/contacts/_fields.html.erb` | the fields of the form |
| `app/views/recourses/_sidebar.html.erb` | a shared partial, for every resource at once |

Templates are looked up under `contacts/`, then `recourses/`, then
`application/`, since those are the controller's prefixes. That is what lets a
partial be replaced for one resource or for all of them — and it is why a
controller of your own should subclass `RecoursesController` if it wants to keep
the gem's views. A controller inheriting straight from `ApplicationController`
has no `recourses/` prefix, so it finds none of them.

A template of yours can still call the gem's partials:

```erb
<% content_for :title, 'States' %>

<%= render 'table', recourses: @resources, pagy: @pagy %>
```

A row partial is rendered once for the header row and once per record. It
declares the record as a strict local, under the singular name of the resource,
and builds its cells with `column`:

```erb
<%# locals: (contact:) -%>
<%= column header: 'Name' do %>
  <%= contact.name %>
<% end %>

<%= column header: 'Created at', class: 'text-nowrap' do %>
  <%= resource_cell contact, 'created_at' %>
<% end %>
```

`column` draws a `<th>` on the header pass and a `<td>` on every other, and its
block runs only for a real record — which is why `contact` arriving as `nil`
for the header row is not a problem.

A fields partial is the same shape, and builds its fields with `field`. Pass
`label:` to override the heading, and `type:` to override the field the column
would have chosen:

```erb
<%# locals: (contact:) -%>
<%= field :phone, type: :phone %>
<%= field :email, type: :email %>
<%= field :name, label: 'First name' %>
<%= field :surname, label: 'Last name' %>
```

The form builder is not a local — it reaches `field` through `@recourse_form`,
so `field :phone` is all the call site has to say.

## Helpers

`RecoursesController` does `helper Recourse::Helpers`, so these are available in
any template or partial it renders. A controller of your own that does not
subclass it can include the module the same way.

Naming the resource on the page:

- `resources_name` — `'Contacts'`
- `resource_name` — `'contact'`
- `resource_key` — `:contact`, the local a row or fields partial receives
- `resource_record` — the record the action built, read from the assigns
- `resource_record_label` — what that record is called, by its model's label

Building a table:

- `column(header:, **, &)` — one cell, a heading on the header pass
- `resource_columns` — the columns a table shows
- `resource_column_title(column)` — a heading, translatable like any attribute
- `resource_cell(record, column)` — one value, formatted by what it holds

Building a form:

- `field(name, label: nil, type: nil)` — one labelled field in the grid
- `editable_columns` — the columns a form offers
- `resource_field(form, column, type: nil)` — the field alone, unlabelled
- `combobox(form, column, association)` — the menu a foreign key offers
- `field_html(column, type = nil, model = resource_model)` — the browser-side
  constraints a column's validators add up to
- `pattern_example(pattern)` — a value the pattern would accept

Foreign keys:

- `belongs_to_association(column)` — the association a column is the key of
- `reference_field`, `reference_cell`, `reference_title` — the field, the value
  and the heading for one

Chrome:

- `resource_breadcrumbs` — the trail to this page, as `[title, path]` pairs
- `sidebar_resources` — every declared resource with an index, in routes order
- `current_resource?(name)` — whether a sidebar entry is this page
- `resource_label(title)` — an icon and a title, for a link to a resource
- `new_resource_path`, `edit_resource_link(record)` — nil and nothing when the
  action is not defined or not routed, so a link never points at a `404`
- `flash_theme(key)` — the Bootstrap theme one flash entry reads in

## What the engine serves

The gem vendors what its pages cannot render without and serves it from
`/recourse/` through `Rack::Static`, so a host needs no asset pipeline:
`bootstrap.min.css`, `bootstrap-icons.min.css` with its fonts,
`bootstrap.bundle.min.js`, `stimulus.js`, and the gem's own
`phone_controller.js`.

It also ships `app/views/layouts/application.html.erb`, which is what renders
when your app has no layout of its own. When it has one — and most do — the
pages render inside yours, so copy those two stylesheets and the Stimulus
module into it to see them styled.

Both the index table and a combobox's list of options render inside `cache`
blocks, keyed on the relation, so configuring a cache store is what turns them
from correct into cheap.

## Ruby API

- `Recourse::VERSION`
- `Recourse.declared` — the resources drawn, in `routes.rb` order
- `Recourse.declare(name)` — records one, ignoring a repeated draw
- `Recourse.editable_columns(model)` — what a form offers and `create` permits
- `Recourse::NAVIGATION_ICONS`, `Recourse::FALLBACK_ICON` — the Bootstrap Icons
  name a sidebar title is drawn with, and the one an unlisted title falls back to
- `Recourse::Error` — the class every failure the gem reports will be, so a host
  can rescue one type
- `Recourse::Routes`, `Recourse::Controllers`, `Recourse::Engine` — the wiring
  behind `recourses`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run
`rake test` to run the tests, or `rake` to run the tests and RuboCop. You can
also run `bin/console` for an interactive prompt.

The test suite boots a dummy Rails app against PostgreSQL, so it needs a server
running; the database itself is created on the first run.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/claudiob/drive.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
