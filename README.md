# Recourse

A `routes.rb` DSL that mounts ready-made resource screens.

Add one line to `config/routes.rb` and Recourse draws the routes and serves the
controller and views needed to browse and edit a resource. Nothing is written
into your app: every controller, template and partial it supplies is a default,
and defining your own takes precedence over it.

> **Status:** early development. All seven actions work; the eject generator is
> not implemented yet.

## Requirements

- Ruby 3.2 or newer.
- Rails 8.1 or newer — `actionpack`, `activerecord` and `railties`.
- `pagy` 43.6 or newer, which paginates every index.
- `ransack` 4.4 or newer, which sorts, searches and filters every index.
- `unicon`, which names the icon a model picks in each design system.

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

Because the third step is plain `resources`, `recourses :contacts` routes all
seven actions, and all seven are answered.

A resource with no `index` route gets no sidebar entry, which is what
`only: []` is for.

A resource names a model, and a name that resolves to none is an error rather
than a mystery: `recourses :pizzas` with no `Pizza` in the app answers

> You declared `recourses :pizzas` in your routes file, but this app has no Pizza
> model.

which is a `Recourse::Error`, so a host can rescue it like anything else the gem
raises. Write the controller yourself if a resource of yours is not backed by a
model at all — the gem defines one only where you have not.

`recourses` works inside a `namespace` too, and the controller it defines follows
the namespace rather than the resource:

```ruby
namespace :admin do
  recourses :sources, only: :index
end
```

draws `/admin/sources` and defines `Admin::SourcesController`, making the `Admin`
module itself if your app has none — a namespace is a routing decision, and Rails
draws it whether or not a module exists to match. The sidebar entry links to
where the routes were drawn, and a namespaced resource and its top-level twin are
separate entries: `/sources` and `/admin/sources` never mark each other as the
page being shown.

## `rails generate recourse`

```
$ bin/rails generate recourse contact name:string phone:string
      invoke  active_record
      create    db/migrate/20260812032723_create_contacts.rb
      create    app/models/contact.rb
      invoke    test_unit
      create      test/models/contact_test.rb
      invoke  controller
      create    app/controllers/contacts_controller.rb
      invoke    erb
      create      app/views/contacts
      invoke    helper
      create      app/helpers/contacts_helper.rb
      create  db/seeds/contacts.rb
      append  db/seeds.rb
       route  recourses :contacts
```

Everything `rails generate resource` writes — the ORM and test framework hooks
are your app's own, so whatever `resource` invokes, this invokes — with two
differences, both of them about handing the model its screens rather than
leaving you to write them:

- The route reads `recourses :contacts` rather than `resources :contacts`.
- The controller inherits `RecoursesController` rather than
  `ApplicationController`. It has to: a controller of your own is exactly what
  step 2 above steps aside for, so an `ApplicationController` one would leave the
  resource with no actions at all.
- It writes `db/seeds/contacts.rb`, so a new resource has something to show on the
  screens it just gained.
- A `references` attribute gets a counter cache, and both sides of the association
  it declares. The migration adds
  `add_column :authors, :posts_count, :integer, default: 0, null: false` after the
  `create_table`; the child reads `belongs_to :author, counter_cache: true`; and the
  parent gains the matching `has_many :posts`, with `dependent: :destroy` since a
  child that cannot exist without its parent goes with it.
  A polymorphic reference gets none of it: it names no one table to count on.

The parent's `has_many` is written only where that model exists already, so
generate the parent first.

That seed file holds two rows, which is the pair every screen is worth looking at
with: one carrying only what the row cannot save without, and one with every
optional attribute assigned as well. A row cannot save without whatever the
migration marks `null: false` — write `name:string!` to mark one — nor without a
`references` attribute, since `belongs_to` requires one. So the bare post below
carries its author, and only its author:

```ruby
Post.find_or_create_by! author: Author.first

Post.find_or_create_by!(author: Author.first, title: 'Everything post') do |post|
  post.content = 'Content'
  post.published_on = Date.current
  post.private = true
end
```

The filled row takes one key more than the bare one wherever nothing required
carries a name to vary — an author is the same author in both — so that
`find_or_create_by!` finds each of them rather than the second finding the first. Values are of each column's own type and nothing more, since the model has no
validators yet to have opinions about them. Both rows are `find_or_create_by!`, so
seeding twice leaves two rows rather than four.

`db/seeds.rb` gains one line, once, however many resources you generate:

```ruby
Dir[Rails.root.join('db/seeds/*.rb')].sort.each { |seeds| load seeds }
```

Alphabetically, so it is deterministic rather than right — reorder by hand where one
resource's rows need another's to exist first. `--no-seeds` writes no seed file.

It takes every option `resource` takes, including `--actions`, which turns the
route back into the `get` lines that generator writes for named actions, and
`admin/market`, which nests the route in a `namespace :admin` block.

## `rails generate recourse:seed`

```
$ bin/rails generate recourse:seed
      create  db/seeds/contacts.rb
      create  db/seeds/markets.rb
      append  db/seeds.rb
```

A seed file for every model your `recourses` routes already serve — the models
you have, rather than one you are generating — so every screen has rows to show.
Each file holds 25 rows: the first carries only what a row cannot save without,
whatever a presence or inclusion validator demands and every required
`belongs_to`; the last fills every attribute; and the rest mix which optional
attributes are filled, so a nullable column is seen both ways on the screens.

```ruby
[
  { phone: '5552340001' },
  { phone: '5552340002', email: 'email2@example.com' },
  { phone: '5552340003', name: 'Name 3' },
  # ... 21 more combinations ...
  { phone: '5552340025', email: 'email25@example.com', name: 'Name 25', surname: 'Surname 25', app: App.first },
].each { |attributes| Contact.find_or_create_by! attributes }
```

Values are of each column's own kind and nothing more, varied by row so a unique
index is satisfied: strings are numbered, an email column gets an address, a
phone column ten valid digits, an enum cycles the words it admits, and a
reference reads the first row of the model it points at — an app's own
attribute type counts as what it subclasses,
so a `Price` seeds as the decimal it is. A validator with stricter opinions is
yours to satisfy by editing the file, and `find_or_create_by!` keeps every run
after the first finding the rows rather than making them again.

`db/seeds.rb` gains the same loader line as above, once. A resource whose model
does not exist is skipped with a note, and a file that already exists asks
before being overwritten.

## The screens

| Action | What it answers |
| --- | --- |
| `index` | one page of the model — 20 rows, `?page=2` for the next |
| `show` | the record the id names, read out |
| `new` | a blank record's form |
| `create` | the index again, or the form with the errors on it |
| `edit` | the form for the record the id names |
| `update` | the index again, or the form with the errors on it |
| `destroy` | the index again, without the record |

`index` reads the model's `recourse_includes` and `recourse_order`, so a table
cell naming a referenced record costs no query of its own. The table hides
every encrypted column, and a model with no rows renders `No contacts.`
instead. A heading sorts the table by its own column where the model allows
it, and the form above the table narrows what it shows, by search or by
filter.

`show` reads one record out where its form would have been: the same grid the
edit page uses, `lg:col-6` so it is two columns on a large viewport, with the
heading a form would give each column above and what the record says below, and a
rule under each row of two. Both pages lay a row out with the same class, and the
edit page reserves the width of that rule without drawing one, so a field sits at
exactly the height of the value it edits and switching tabs moves nothing but the
controls. No
form and no field — a value the record has nothing for reads as an em dash. It
lists the same columns the form offers, so the two pages never disagree about
which attributes a record has.

Each value reads as what it is of rather than as what it is stored as: a boolean is
an icon — a tick, a cross, or an empty square for the one a record never answered —
an enum is a badge, an integer carries its delimiters, a decimal is rounded to its
own scale, a `:price` wears the currency and a `:percentage` a `%`, and a phone is
punctuated. A counter cache is not shown at all, being Rails' to keep rather than
anyone's to read. The kinds and the helpers behind them are the table under
["What a field becomes"](#what-a-field-becomes), which the form reads too — one
question, two answers.

Encrypted columns are among them, and they arrive masked: one `*` per character,
with a `Show` beside it that swaps the plaintext in. The value travels in a
`data-reveal-plain-value` attribute and a Stimulus controller does the swap, so a
screenshot of the page catches asterisks and reading one value is a deliberate
click. Encryption settles what the database keeps; the mask settles what a screen
gives away.

`show` and `edit` are what an index row links to, an eye then a pencil, and each
appears only where its action is both implemented and routed. A resource with
neither gets no `Actions` column at all.

Both pages wrap their content in a Bootstrap card whose header is a row of tabs,
one per page the record has — `Show` behind the eye, then `Edit` behind the
pencil, with the page being read marked `active` and `aria-current='page'`. They
are links rather than a JavaScript tab set, since each is a page of its own; a
resource with only one of the two gets a card with one tab.

`new`, `show` and `edit` assign the record twice: to `@recourse`, and to the name
Rails would use, so `@contact` is what a view of yours can read.

`destroy` is offered from the edit page, as a button beside the breadcrumb, and
only where the action is both implemented and routed. It asks first, through
`data-turbo-confirm`, naming the record and counting one level of what goes with
it: `2 messages will be deleted with it.` for a `dependent: :destroy`,
`1 message will be kept, without a job.` for a `:nullify`, and
`Anything under those goes too.` in place of the levels below — a state reaches
counties, then ZIPs, then locations, and counting that far would join 40,965 rows
to draw one page. Without Turbo loaded there is no confirmation at all, only the
delete.

`create` and `update` permit every editable column, then take one of two
branches. Saved, they set `flash.notice` to `Contact was created.` and redirect
to the index with `303 See Other`; rejected, they set `flash.now.alert` and
re-render the form with `422 Unprocessable Entity`. `show`, `edit`, `update` and
`destroy` look their record up with `find`, so an id that names nothing raises
`ActiveRecord::RecordNotFound` and Rails answers `404`.

Two column lists decide what a screen shows, and they are deliberately not the
same one:

- A table shows every column except the encrypted ones, so a column holding PII
  never reaches an index page, and except the primary key and anything the model
  declares `attr_readonly`. `created_at` and `updated_at` are shown only where a
  model asks for them by name — `def recourse_timestamps = %i[created_at]` — and
  come last when it does, after whatever the record is actually about.
- A form offers, and `create` permits, `Recourse.editable_columns` — every
  column except `id`, `created_at`, `updated_at` and any counter cache. Encrypted
  columns are offered, as password fields carrying the record's own value — masked
  by the browser, and there so that saving a change to one column does not demand
  every encrypted one be retyped.

The show page reads from the second of those two, the form's list, which is why an
encrypted column reaches it — masked — while no index table draws one at all. A
table is a page of records and a screenful of PII; a show page is one record, read
on purpose.

A column holding a counter cache is headed with what it counts — `ZIPs` rather
than `ZIPs count` — which the gem reads from the `counter_cache` on the other side
of the association rather than from the column's name. Every cell in it leads with
the icon of what is counted, so `<i class='bi bi-geo-alt'></i> 26`.

A cell renders by what the column holds: a `belongs_to`'s foreign key as the
label of the record it points at, a time as `Aug 4 at 03:47pm EDT`, a `phone`
through `number_to_phone`.

## What a model can say

Every Active Record model answers four class methods: the engine extends
`ActiveRecord::Base` with `Recourse::Recoursive` on load, so the defaults are
there without a model mentioning them.

| Method | Default | What it decides |
| --- | --- | --- |
| `recourse_icon` | the model's own name, as a concept `Unicon` resolves | the icon a link to this resource is drawn with |
| `recourse_label` | `:name` | the column that stands for a record — what a combobox lists, and what a table cell shows for a foreign key pointing here |
| `recourse_typed_label?` | true when that column has a length validator | whether a foreign key to this model is typed into a text field or picked from a list |
| `recourse_includes` | every `belongs_to` the table names | what the index eager-loads, in any shape `includes` accepts |
| `recourse_order` | `:id` | how the index sorts, in any shape `order` accepts |
| `recourse_timestamps` | `[]` | which of `created_at` and `updated_at` the table ends with |

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

The engine extends every model with `Recourse::Searchable` too, loaded right
after Ransack so its `extend` lands ahead of Ransack's own defaults in the
singleton ancestor chain — ours win. These are the hooks behind a sortable
heading, a search box and a filter:

| Method | Default | What it decides |
| --- | --- | --- |
| `ransackable_attributes` | every column but the encrypted ones, plus any encrypted column a search can match whole | which columns a search or a filter may read |
| `ransackable_associations` | the foreign keys the search box reaches through | which other tables a predicate may join |
| `ransortable_attributes` | the timestamps, every column an index covers and every counter cache, less every foreign key | which headings can be clicked to sort |
| `search_field` | every indexed string column a table shows, plus the label behind every foreign key whose model is too long to list, ORed and matched on containment — or, for a model with none of those, its deterministically encrypted indexed columns, matched whole | what the search box searches — nil where there is nothing to look through, and no search box either |
| `search_prompt` | `Filter by`, then those same columns joined by `or`, in lower case but for the acronyms | what the search box says while it is empty |
| `filter_fields` | one `_in` entry per enum, then one per `belongs_to`, less the ones the search box reaches through | which columns get a filter, and what draws each |
| `recourse_searchable?` | true when there is a search field or any filter | whether the form above the table renders at all |
| `recourse_listable?` | true when the table holds no more than `MENU_LIMIT` rows | whether a foreign key pointing here gets a menu or joins the search |

A `State` answers `'code_or_fips_or_name_cont'` for the first and `'Filter by
code or fips or name'` for the second, since `code`, `fips` and `name` are its
only columns that are both indexed and a searchable type — a string, text,
citext or enum, an enum's value being a word even though its own Postgres type
is not. An index is the only signal a schema carries about which column
identifies a row rather than describes it, so that is what both hooks read. The
prompt reads in lower case, except for the words Rails was told are acronyms:
`/locations` prompts `Filter by ZIP code`, not `filter by zip code`. Everything
the gem lower-cases goes through `Recourse.downcase`, which leaves a registered
acronym as it found it — the same call behind `No ZIPs.` and `All ZIPs`.

A foreign key is the other half of what a search looks through, and what decides
is how long the other table is. A menu is a control while every row fits in one;
past that it is a page of HTML nobody reads. So a `belongs_to` whose model is not
`recourse_listable?` — more than `MENU_LIMIT`, which is 100 — gets no filter, and
its label joins the search instead. `/locations` answers `'zip_code_cont'` for
40,965 ZIPs; `/zips` answers `'code_or_county_name_cont'` for 3,144 counties and
keeps the menu for its markets. Each names that one association in
`ransackable_associations`, so exactly the join being searched is allowed.

A model whose only searchable columns are encrypted is searched differently, and
`/agents` is the case: an email is encrypted, so a `cont` would read ciphertext
and match nothing. Where a model has no plaintext column worth searching, the
search box asks for a whole value instead — `email_eq`, prompted `Filter by exact
email` — which works because Active Record encrypts the term the same way it
encrypted the column. Only *deterministically* encrypted columns qualify: without
`deterministic: true` two writes of one address are two different ciphertexts, so
nothing would ever compare equal. Sorting is never offered on any of them, since
what an ORDER BY would sort is the ciphertext.

The label has to be a word for that to mean anything — a string, text, citext or
enum — since a `cont` against an id or a date matches nothing. A model too long
to list whose label is neither leaves the foreign key with no filter and no
search, and `scope:` on a `filter_fields` entry is what draws a menu for it
anyway.

No foreign key's column is sortable, these included: the cell shows a label from
another table, and the id under it is not the order that label reads in.

`recourse_listable?` counts once per class and counts no further than it has to —
`LIMIT 101` — so the question costs 0.03ms whether the table holds ten rows or
ten million. A table that crosses the line is noticed at the next boot.

Overriding one is the same shape as `Recoursive`: a same-named concern beside
the model, defining inside `class_methods do`. The dummy app's `Market` widens
its search past what an index suggests, and renames the filter it is narrowed
with:

```ruby
# app/models/market/searchable.rb
class Market
  module Searchable
    extend ActiveSupport::Concern

    class_methods do
      def search_field = 'name_or_email_cont'

      def search_prompt = 'Filter by name or email'

      def filter_fields = { 'state_id_in' => { label: 'Home state' } }
    end
  end
end
```

```ruby
# app/models/market.rb
class Market < ApplicationRecord
  include Searchable
end
```

## What a field becomes

Two questions split the two kinds of foreign key, and either one sends it to a
text field. `recourse_typed_label?` asks whether the label is bounded — a length
validator — and so can be typed: a ZIP code can. `recourse_listable?` asks
whether the table is short enough that a menu of every row is a control rather
than a page: 3,144 counties are not. A county name answers no to the first and
still gets a text field through the second, which is the same call the filter
beside it makes.

Either way the field asks for the label under the foreign key's own name, and
the controller looks the record up on the way in — `ZIP.find_by code: '90210'` —
so no model needs a virtual attribute and no strong parameter needs a special
case.

| Column | Field |
| --- | --- |
| a foreign key whose label is typed, or whose table is too long to list | text field, resolved to an id on submit |
| any other foreign key | a searchable combobox of every record, by label |
| a counter cache | none: Rails keeps it, so no form offers it and `create` does not permit it |
| `phone` | telephone field, typing its own separators as it goes |
| an encrypted attribute | password field, prefilled |
| `email` | email field |
| a `boolean` | checkbox, under its label like every other control |
| an `enum` | a combobox of the words it admits, one at a time |
| an `integer` | number field, `step="1"` |
| a `float` | number field, `step="any"` |
| a `decimal` | number field stepped by its scale and capped by its precision — `scale: 2, precision: 4` gives `step="0.01" max="99.99"` |
| a `:price` | the same, with the currency in a `.form-adorn-text` before it |
| a `:percentage` | the same, with `%` after it, through `.form-adorn-end` |
| a `date` or `datetime` attribute | date or `datetime-local` field |
| anything else | text field |

The type comes from the model's own `type_for_attribute`, so an `attribute
:opens_on, :date` override counts, and so do its `precision` and `scale` —
`columns_hash` is never asked.

`:price` and `:percentage` are types your app defines, not hooks this gem asks
for. A `decimal` says how many digits it keeps and nothing about what they mean,
so if you want `$95.00` and `15.00%` on your pages, register the types that say
so:

```ruby
# app/types/price.rb
class Price < ActiveRecord::Type::Decimal
  PRECISION = 10
  SCALE = 2

  def initialize(precision: PRECISION, scale: SCALE, **) = super
  def type = :price
end

# config/initializers/types.rb
ActiveSupport.on_load :active_record do
  ActiveRecord::Type.register(:price) { |_name, **options| Price.new(**options) }
end

# and in the model
attribute :hourly_rate, :price
```

The gem asks the attribute what it is and formats what it hears, so a type of
your own is all it takes. Give migrations the same word by extending
`ActiveRecord::ConnectionAdapters::TableDefinition` — Rails keeps
`define_column_methods` private, so write the method out:

```ruby
module MoneyColumns
  def price(*names, **options)
    names.each { |name| decimal name, precision: Price::PRECISION, scale: Price::SCALE, **options }
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.include MoneyColumns
```

Then `t.price :hourly_rate` and `attribute :hourly_rate, :price` are the same
decision said twice, once to the database and once to the page. `test/dummy` does
all of this, for `:price` and `:percentage` both.

A phone is a phone before it is ciphertext: an encrypted `phone` gets the
telephone field rather than the password one, since the field types its own
separators and a password box would hide the fact. The show page still masks it.

What the browser then enforces is read from the validators, never from the
schema: `maxlength` and `minlength` from a length validator, `pattern` from a
format validator's regexp with its anchors removed, `required` from a presence
validator on the column or on the association, a numeric `inputmode` where the
pattern admits only digits. A field with a pattern also gets a `title` naming a
value that would match, and an optional field gets `Optional` as its
placeholder. A constraint your database has and your model does not is a
constraint no field can show.

## Sorting, searching and filtering

A heading sorts its own column when the model's `ransortable_attributes`
allows it. The row partial draws every heading through `sort_header(name)`
rather than a bare title:

```erb
<%= column header: sort_header('name') do %>
  <%= resource_cell record, 'name' %>
<% end %>
```

It returns a sort link only on the header pass, with its own caret — up for
ascending, down for descending, none where nobody sorted by that column — and
the plain title on every other pass, so a `<td>`'s `data-cell` stays readable
text. The link restarts the table at its first page, since a sort keeps
whatever the request was already searching or filtering by and only replaces
the order.

The index builds a GET form — a search box for the model's `search_field`, one
filter per `filter_fields` entry, nothing at all where `recourse_searchable?` is
false — and puts it in `content_for :search` rather than drawing it anywhere. The
gem's layout yields it in the navbar, to the right of the breadcrumb and the
buttons; a layout of your own has to `yield :search` the same way it yields
`:actions`, or the form is built and never shown. A filter reuses the combobox from
"Comboboxes for foreign keys" with `multiple: true`, so a request can narrow a
table to more than one of what a foreign key points at — `?q[state_id_in]=1,2`
for two states at once.

Where the model a filter lists keeps a counter cache of the rows being filtered —
`markets.zips_count` on `/zips` — every option in that menu ends with the count, at
the right of its row and in muted text and in the menu alone: a closed box showing
one chosen option reads its name and nothing else. The menu is ordered by that count rather
than by name: the choice most of the rows are behind is the first offered, with the
name breaking a tie. A menu with no count to read is still ordered by name. An option counting none of them is in the
menu without being on it: `d-none` until the `All markets` line at the top is
clicked, which reveals every one of them as well as unticking whatever was ticked.
One already ticked stays visible either way, or the box would name a filter its own
menu does not offer. It comes from the same
`recourse_counters` the table's own headings read, so a `zips_count` nobody
maintains is not mistaken for a count of anything, and it is fetched by widening
the two-column `SELECT` the menu already makes rather than by a query of its own.

Every enum gets one too, and gets it first: `/bookings` opens with a `Status`
menu of the words that column admits, `?q[status_in]=scheduled,fulfilled` for two
of them at once. The words are the model's own `defined_enums`, the same ones the
form's menu offers and a show page draws as a badge, and the way back reads `All
statuses` — the column's name rather than a model's, since a status belongs to the
table being read and not to another one. A foreign key whose model is too long to list — the ZIP
on `/locations`, the county on `/zips` — is offered no filter at all, since the
menu would be the whole table. Its label goes into the search box instead:
`?q[zip_code_cont]=005` narrows one page by joining `zips`, and
`?q[code_or_county_name_cont]=Autauga` narrows the other by joining `counties`.
Naming that predicate in `filter_fields` with a `scope:` still offers a menu,
over whichever relation the scope names.

Typing in the search box, or picking from a filter's menu, submits the form
itself — a Stimulus controller resubmits 300ms after the last keystroke, and
immediately on every option ticked or unticked. Only the table and its
pagination are replaced by the answer: they sit in a `<turbo-frame id='results'>`
that the form targets, so an open menu stays open, the caret stays where it was
typing, and the address bar still advances to the query that produced the table.
Without Turbo the same form is an ordinary GET that reloads the page, and the
caret is put back into the search box by hand.

What a search matched is marked in the cell that matched it, so twenty rows that
all matched still say why each one did. Only the columns the search looked
through are marked — including the label behind a foreign key it reached
through, so `/locations` marks the ZIP code. A row partial of your own gets the
same by calling `search_highlight`.

Links need to know about that frame. A heading's sort and a pagination link
navigate it, which is the point of it — and that sort is read back off the URL
into the form's hidden `q[s]`, so the next search keeps the order the last click
asked for. **Every other link in a table has to leave the frame**, since the page
it goes to has no frame of that name and Turbo would answer `Content missing`.
The edit pencil does; a row partial of your own should use `turbo_link_to`, which
is `link_to` with `data-turbo-frame='_top'` already on it:

```erb
<%= column header: 'Name' do %>
  <%= turbo_link_to contact.name, contact_messages_path(contact) %>
<% end %>
```

A model overrides any of this in its own `Searchable` concern; see "What a
model can say".

What this costs:

- A search reads the whole table: a `cont` predicate is `ILIKE '%…%'`, which
  cannot use a btree index.
- A filter's combobox selects every row of the model it offers, which is what
  the typed-label rule and a `scope:` are both for.
- A search that reaches through a foreign key joins that table, and the
  containment is never indexed there either. Which side the planner drives from
  decides the cost: with few rows on this side it index-scans the other and
  tests each match, and with many it scans the other table once and hashes.
- A sort Ransack applies has no tiebreaker, so rows tied on the sorted column
  can shuffle between pages.
- Pagy's own count runs on the filtered relation, so a narrower filter is a
  cheaper count too, not just a shorter table.

## Overriding a screen

Anything your app defines wins, because your app's view paths come first and
`define_missing` steps aside for a controller that already exists.

| Define this | To replace |
| --- | --- |
| `app/controllers/contacts_controller.rb` | the whole controller |
| `app/views/contacts/index.html.erb` | the index template — `show`, `new` and `edit` the same way |
| `app/views/contacts/_row.html.erb` | the cells of one row |
| `app/views/contacts/_fields.html.erb` | the fields of the form |
| `app/views/contacts/_values.html.erb` | the values the show page reads out |
| `app/views/recourses/_card.html.erb` | the tabbed card the show and edit pages sit in |
| `app/views/recourses/_sidebar.html.erb` | a shared partial, for every resource at once |

Clear the cache after adding one. The index table renders inside a fragment
whose key is a digest of the templates the gem resolved when it was written, so
a `_row.html.erb` that appears afterwards does not expire it: the page keeps
serving the table it drew before your partial existed, and a file watcher will
not help. `bin/rails tmp:cache:clear` is the whole fix, and it is only ever
needed the once.

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

A values partial is the same shape again, for the show page, and builds its rows
with `value`. It needs no builder at all, so `label:` is the only option:

```erb
<%# locals: (contact:) -%>
<%= value :name, label: 'First name' %>
<%= value :phone %>
```

## Rewording anything it says

Every string the gem renders comes from `config/locales/recourse.en.yml` under
the `recourse` key, so rewording one takes a locale file of your own rather than
a reopened helper:

```yaml
# config/locales/en.yml
en:
  recourse:
    add: Create a new %{model}
    none: "Nothing here yet."
    select: Select an airplane…
```

The model's own name is `%{model}` and its plural `%{models}`, and both come from
`model_name.human` — so translating `activerecord.models.contact` renames it
everywhere at once, in the button and the flash alike.

The gem's own copy carries no `a` or `an` anywhere it interpolates a model,
because which one is right depends on how the word sounds rather than how it is
spelled — *an hour*, *a user*, *a ZIP*, *an SMS* — and no rule gets that right in
every language a key might be translated into. `Select…` says as much as `Select
a State…` under a label that already reads `State`. If your models all take the
same article, the keys above are where you say so.

## Recolouring it

```ruby
# config/initializers/recourse.rb
Recourse.color = :orange
```

Bootstrap's primary colour is blue, and one line makes it one of five others:

```ruby
Recourse::COLORS # => [:blue, :orange, :purple, :pink, :brown]
```

Every button, link, sorted heading, focus ring and favicon follows, because `.theme-primary`
and everything else Bootstrap draws in that colour read the nine `--bs-primary-*`
custom properties that the gem's layout redefines under `:root` when a colour is
set. Nothing is emitted when it is nil, which is the default.

Five of the sixteen families Bootstrap ships, and the other eleven are left out
rather than forgotten: `--bs-primary-contrast` is white, and these five are the
ones dark enough at their 500 step to carry white text. Anything else raises a
`Recourse::Error` naming the five, rather than writing `var(--bs-purpel-500)` into
every page and going unnoticed until somebody looked at a button.

A host that wants the eleven, or a palette of its own, overrides
`app/views/recourses/_color.html.erb`, which takes the family as its one local.

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
- `search_highlight(value, column)` — that value with the current search marked
  in it, where the search looked through that column at all
- `sort_header(column, title = nil)` — a heading that sorts by that column
  where the model allows it, the plain title otherwise. It calls Ransack's
  `sort_link` rather than replacing it, so that helper stays yours to use

Searching and filtering:

- `search_form` — the search and filter form, or nothing where the model offers
  neither a search field nor a filter. The index hands it to `content_for
  :search`, so a layout is what decides where it goes
- `filter_field(predicate, label: nil, scope: nil)` — one filter, a multiple
  combobox of the records a foreign key points at

Reading one out:

- `value(name, label: nil)` — one labelled value in the show page's grid, the
  heading a form would give the column above what the record says below
- `resource_value(column)` — that value alone, an em dash where there is none.
  `value` is what masks an encrypted one; this is the value itself
- `formatted_value(column)` — the value formatted by what the column holds, with
  no em dash and no mask
- `attribute_kind(column)` — what the column holds, as `:counter`, `:price`,
  `:percentage`, `:enum`, `:phone` or the attribute's own type. The one question
  the show page and the form both answer
- `icon_tag(concept, label: nil)` — one Bootstrap icon, by the concept Unicon
  names it under rather than by what this set happens to call it

Building a form:

- `field(name, label: nil, type: nil)` — one labelled field in the grid
- `editable_columns` — the columns a form offers
- `resource_field(form, column, type: nil)` — the field alone, unlabelled
- `kind_field(form, column, **options)` — the field a column's kind deserves, which
  is what `resource_field` falls through to
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
- `sidebar_resources` — every declared resource with an index, in routes order,
  each with the position of the letter that reaches it from the keyboard
- `current_resource?(name)` — whether a sidebar entry is this page
- `resource_label(resource, title, key = nil)` — the icon its model picked and a
  title, for a link to a resource, with the letter at `key` marked as its
  keyboard shortcut
- `new_resource_path`, `show_resource_link(record)`, `edit_resource_link(record)`,
  `destroy_resource_button(record)` — nil and nothing when the action is not
  defined or not routed, so a link never points at a `404`
- `resource_links(record)` — both row links together, or nothing where a row has
  neither; `resource_actions?` is what the table asks before drawing the column
- `resource_tabs(record)` — the pages a record has as `[label, path, current]`, which
  is what the card's header draws
- `destroy_warning(record)` — the text that button asks for confirmation with
- `turbo_link_to(name, path, **options)` — `link_to` for a link inside a table,
  carrying the `data-turbo-frame='_top'` that takes it out of the results frame
- `flash_theme(key)` — the Bootstrap theme one flash entry reads in

## What the engine serves

The gem vendors what its pages cannot render without and serves it from
`/recourse/` through `Rack::Static`, so a host needs no asset pipeline:
`bootstrap.min.css`, `bootstrap-icons.min.css` with its fonts,
`bootstrap.bundle.min.js`, `stimulus.js`, and the gem's own Stimulus
controllers — `clear`, `deselect`, `favicon`, `phone`, `reveal`, `search` and
`shortcuts`.

It also ships `app/views/layouts/recourses.html.erb`, and that is the layout its
screens render in — yours is not involved. `RecoursesController` implies
`layouts/recourses`, which Rails finds in the gem before it falls through to
`layouts/application`, so the screens arrive styled in an app that has done nothing
but draw a route: the stylesheets, the Stimulus controllers, the navbar, the
sidebar, the favicon and the search slot are all the gem's to place.

Two ways to put your own chrome back, where an admin page should carry it:

```erb
<%# app/views/layouts/recourses.html.erb — yours wins, being earlier in the view paths %>
<%= render template: 'layouts/application' %>
```

```ruby
# or a controller of your own, which keeps everything else the gem defines
class ContactsController < RecoursesController
  layout 'application'
end
```

Either way the screens are then inside your layout, which has to link the two
stylesheets from `/recourse/`, register the Stimulus controllers, and yield what
the screens contribute: `yield :title`, `yield :actions` and `yield :search`. The
`<link rel='icon' data-controller='favicon'>` line is worth copying too, or the tab
keeps whatever icon your app already had.

Named `recourses` rather than `application` on purpose. A gem shipping
`layouts/application` is a layout an app with none of its own would render *its own*
pages in — the engine's view paths answer for `layouts/application` as readily as
for anything else — and this one is a navbar and a sidebar for someone else's admin
screens.

The index table renders inside a `cache_if params[:q].blank?, recourses`
block, so a sorted or filtered table is drawn live instead of cached — two
requests can share a relation and still want different headings. A
combobox's list of options renders inside `cache [recourses, multiple,
selected]`, since the same relation is different markup as a single form
combobox and as a multiple filter, and the same menu is different markup
again with a different selection. Configuring a cache store is what turns
what is cached from correct into cheap.

## Ruby API

- `Recourse::VERSION`
- `Recourse.declared` — the resources drawn, in `routes.rb` order
- `Recourse.declare(name)` — records one, ignoring a repeated draw
- `Recourse.model(name)` — the model a resource is named after, or a
  `Recourse::Error` naming the routes line to fix
- `Recourse.color` / `Recourse.color=` — the Bootstrap colour family the pages
  call primary, one of `Recourse::COLORS`, or nil for Bootstrap's own blue
- `Recourse::COLORS` — `%i[blue orange purple pink brown]`
- `Recourse.icon(name)` — what that model's `recourse_icon` is called in
  Bootstrap Icons
- `Recourse.model_icon(model)` — the same for a model already in hand
- `Recourse.editable_columns(model)` — what a form offers and `create` permits
- `Recourse::Search` — the Ransack search behind an index; `query` is the
  `Ransack::Search` the views read as `@q`, `scope` is the relation `index`
  paginates
- `Recourse::Error` — the class every failure the gem reports will be, so a host
  can rescue one type
- `Recourse::Routes`, `Recourse::Controllers`, `Recourse::Engine` — the wiring
  behind `recourses`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run
`rake test` to run the tests, or `rake` to run the tests and RuboCop. You can
also run `bin/console` for an interactive prompt.

The test suite boots a dummy Rails app against SQLite, so there is no server to
run: the database is a file under `test/dummy/storage`, created and migrated on
the first run, and deleting it is the reset. SQLite is the dummy app's choice,
not the gem's — nothing in the gem names an adapter, so a host running
PostgreSQL or MySQL is served the same screens. What follows from a column kind
only one adapter has follows only there — a citext column, say — and everything
else is read through Active Record's own neutral answers.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/claudiob/drive.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
