# Design Guidelines

**Scope:** how the pages this gem serves look and are marked up. `CLAUDE.md` is
the authority for code style; this file is the authority for design. Read it
before writing or editing any layout, view or partial.

## Bootstrap 6 Alpha for all markup

- Every layout, view and partial follows Bootstrap 6 Alpha.
  Reference: https://v6-dev--twbs-bootstrap.netlify.app/llms-full.txt
- Check class names against those docs rather than recalling v5, which renames
  plenty: responsive utilities are prefixed (`md:col-6`, not `col-md-6`),
  `.bg-light` / `.bg-dark` gave way to the `.bg-1` / `.bg-2` scale, and
  `.text-body-secondary` is now `.fg-2`.
- Page wrappers use `.container-fluid`, never `.container`. A table wants the
  whole width, not a centered column with margins either side.
- Still current from v5: `.container-fluid`, `.table`, `.table-responsive`, and
  `data-bs-theme="light|dark"` — though `color-scheme: light dark` on `:root`
  follows the system, so most pages need no theme attribute at all.
- The gem ships `layouts/application.html.erb` for hosts with none: Bootstrap's
  CSS in the head, the JS bundle as a module before `</body>`, Geist and Geist
  Mono from Google Fonts.
- Bootstrap is *vendored*, not linked: `vendor/recourse/` holds
  `bootstrap.min.css`, `bootstrap.bundle.min.js`, `bootstrap-icons.min.css` and
  the two icon fonts, and the layout asks for `/recourse/…`. The v6 CSS is
  served from a preview host, and a CDN that moves takes every page with it.
- The icon fonts are not optional: `bootstrap-icons.min.css` reaches for
  `fonts/bootstrap-icons.woff2` beside itself, and without it every icon is a
  blank box.
- The engine serves them with `Rack::Static`, since a host may run no asset
  pipeline — see CLAUDE.md, "Vendor what a page cannot render without".

## The navbar

- Every page opens with a navbar holding a breadcrumb, then `yield :actions`,
  both to the left. Nothing else belongs there, and a view contributes buttons
  with `content_for :actions`.
- The breadcrumb ends at the current page, and that last item is *not* a link:
  a `<span class='breadcrumb-link active'>` inside an
  `<li class='breadcrumb-item' aria-current='page'>`. Bootstrap's own example
  uses an `<a>`; we deliberately do not.
- Earlier items are links carrying the resource icon, separated by empty
  `<li class='breadcrumb-divider'>` elements — v6 draws the chevron from that
  element, not from a CSS `content` string as v5 did.
- An index has one item, its own name. Any other page links back to the index
  first: `/counties/new` reads `Counties`, then `New county` as plain text.
- A breadcrumb link and its sidebar twin line up vertically, which constrains
  both. The `<nav class='navbar'>` carries no horizontal margin or padding of
  its own, so both columns reduce to `container-fluid` (0.75rem) plus a link
  padding of 0.75rem — the sidebar's own 0.75rem is canceled by `.row`'s
  negative margin. Any `px-*` or `mx-*` on the navbar shifts the breadcrumb out
  of line by exactly that much.
- `.breadcrumb-link` needs `gap-2`. Both link types are flex but only
  `.nav-link` ships a `gap`, and a whitespace-only text node is not a flex item,
  so without it the icon and text touch while the sidebar's sit 0.5rem apart.
- An index offers `Add <resource>` only where the `new` route is drawn *and* the
  controller implements the action, or the button would 404 or raise. Classes:
  `btn theme-primary btn-sm btn-outline ms-3`.

## Icons on resource links

- A link to a resource is preceded by a Bootstrap Icon in the `<i>` form:
  `<i class='bi bi-person-rolodex'></i> Contacts`.
- **No list of icon names lives anywhere.** A model says what it is drawn with
  by answering `recourse_icon` in its own `Recoursive` concern — the same place
  `recourse_label` is overridden, and for the same reason:

      class County
        # How a county is drawn. One name serves every icon set.
        module Recoursive
          extend ActiveSupport::Concern

          class_methods do
            def recourse_icon = :map
          end
        end
      end

- A bare symbol means every set calls it the same thing. Where they differ,
  answer a hash keyed by set — `:android`, `:bootstrap`, `:ios`:

      def recourse_icon
        { bootstrap: :'person-rolodex', ios: :'person.crop.circle', android: :contacts }
      end

- `Recourse.icon(name, system)` resolves it. A resource with no model of its own
  takes `Recoursive::ICON`, a plain `circle`, which every set has.
- The console asks for `:bootstrap` and the app for `:ios`, following the
  request's variant, and the answer travels in every row's JSON — so no list of
  Apple names lives in the app either.
- Add a set to `ICON_SYSTEMS` and each model can name itself in it.
- Icons go on *links*, so the breadcrumb's current-page item carries none.

## The sidebar

- Below the navbar, an `<aside>` left of the content holds a vertical
  `ul.nav.flex-column`, one link per resource `recourses` drew, in the order
  `config/routes.rb` declares them — never sorted.
- The current page's entry is `nav-link active` with `aria-current='page'`,
  matched on the controller rather than the URL, so `/contacts?page=2` still
  marks Contacts active.
- A resource appears only if its `index` is routed: `recourses :drafts,
  only: :new` gets no link rather than a broken one.
- Layout is `.row` with `aside.col-auto` and `main.col`, inside
  `.container-fluid`.
- The aside's border runs to the bottom of the window, which takes a chain of
  three: `body.d-flex.flex-column.min-vh-100`, then
  `.container-fluid.flex-grow-1.d-flex`, then `.row.flex-grow-1`. It stretches
  because `.row` is a flex container and Bootstrap leaves `align-items` unset.
- `min-height`, not `height`, so short pages fill the window without a scrollbar
  and long ones still scroll.

## Forms

- The gem serves `new.html.erb` (title `New <resource>`) and `edit.html.erb`
  (titled after the record — whatever its `recourse_label` names, so a market
  reads `Chicago`), both rendering the *same* `form` partial with the record
  passed under its own name. A host writes one `_fields.html.erb` and gets it on
  both pages.
- After a rejected update the title shows what was typed, since the record
  already carries the submitted values. Blanking the label blanks the title.
- The form is `form_with model:` plus one field per *editable* column — every
  column but `id`, `created_at` and `updated_at`. Encrypted columns are editable
  even though the table will not display them.
- Each field is a `.form-label` and a `.form-control` inside `.mb-3.lg:col-6`,
  the whole set in one `.row`: two fields to a row on a large viewport, stacked
  below it. A name or a phone number needs nowhere near a full page width, and a
  column of full-width inputs reads as empty space.
- The submit is `btn btn-solid theme-primary`. In v6 the fill is a separate
  class from the base: `.btn` sizes, `.btn-solid` / `.btn-outline` /
  `.btn-subtle` fill, `theme-*` colors.
- An optional field carries `placeholder='Optional'`; a required one carries
  `required` so the browser turns the form back first. Both read *required* from
  the model's validators, never from `null: false` — and a `belongs_to`
  validates the association, so `state_id` counts as required through `:state`.
- A required field shows the shape it expects instead of a placeholder:
  `555-555-5555`, `michael@example.com`. Where there is nothing useful to show,
  it has none.
- An explicit `type:` picks the sample on its own, required or not: `field
  :email, type: :email` on an optional column shows `michael@example.com`
  rather than `Optional`.
- Worth knowing before there is an `edit` action: a required encrypted attribute
  is a required password field, which renders empty, so editing would demand the
  value be retyped. Revisit the rule then, not now.
- The field list is its own `fields` partial, so a host can replace the fields
  without rewriting `form_with` or the submit. It renders one `field` per
  editable column; a host writes the calls it wants by hand.
- `field` takes the column name, `label:` and `type:`. An explicit type is an
  instruction and beats every rule below, the encrypted-column one included.
- Otherwise the type follows the column, in this order: a foreign key is a
  combobox; an encrypted column is a password field; one named `email` or
  `color` gets that input; a `date`, `time` or `datetime` attribute gets its own
  (the last as `datetime-local`); everything else is text.
- Encryption wins over the name, so an encrypted `email` is masked rather than
  typed as an email — protecting the value beats the keyboard.
- Length, format and numericality travel to the browser, all read from the
  *validators*: `maxlength` / `minlength` from a length validator's `maximum`,
  `minimum` or `is`; `pattern` from a format validator with `\A` and `\z`
  stripped, since an HTML pattern is anchored already; `inputmode: 'numeric'`
  from a numericality validator or a digits-only pattern.
- A field with a `pattern` also carries a `title` showing the shape:
  `\d{5}` gives `title='Please match the format 00000'`. Without one the browser
  says only that the value does not match, which tells nobody what would. The
  example is read off the pattern — `\d` a digit, `\w` a letter, a bracket class
  its first character, `{n}` repeats — so `[2-9]\d{2}[2-9]\d{6}` reads as
  `2002000000`.
- Always pass `size: nil`. Rails mirrors `maxlength` into `size`, and a
  five-character box for a ZIP undoes the width rule above.
- Which input a `date`, `time` or `datetime` gets is the one thing no validator
  can say, so it comes from `type_for_attribute` — never `columns_hash`.

## Comboboxes for foreign keys

- A form asks for a foreign key one of two ways, and the label decides. With a
  *length validator* it is short enough to type, so the field asks for the
  value; otherwise it is a combobox.
- A typed reference names both: the label reads `ZIP code`, not `ZIP`. It takes
  its shape — `maxlength`, `minlength`, `pattern`, `title`, `inputmode` — from
  the model the attribute belongs to, but takes *required* from the association
  that needs it, which is the page's model.
- This is what keeps a form from being enormous. `/locations/new` was 3.3 MB
  with its 40,965 ZIPs in a combobox and is 6.4 KB with the code typed. A
  combobox is right for fifty states and wrong for forty thousand ZIPs.
- A value matching no record leaves the foreign key nil, so `belongs_to` reports
  `Must exist` beside the field, which keeps what was typed. That value comes
  from `params`, not the record — nothing was ever assigned.
- `state_id` is a Bootstrap combobox listing each `State` by `name`, in the
  "Search menu items" form, so fifty stays usable.
- Each option reads the model's own `recourse_label` — see CLAUDE.md, "Every
  model says how it is labeled".
- The menu holds every row and Bootstrap filters what is already in the DOM, so
  it is only as usable as the table is small; there is nothing cheaper short of
  a server-side search.
- The markup is the toggle followed by its `.menu` **sibling** — the plugin
  finds the menu with `SelectorEngine.next`, so anything between breaks it:

      <button class='form-control combobox-toggle' type='button' id='county_state_id'
              data-bs-toggle='combobox' data-bs-name='county[state_id]'
              data-bs-placeholder='Select a State…' data-bs-search='true'>
        <span class='combobox-value'>Select a State…</span>
        <i class='bi bi-chevron-down combobox-caret'></i>
      </button>
      <div class='menu'>
        <div class='combobox-search'>
          <input type='text' class='form-control combobox-search-input'
                 placeholder='Search…' autocomplete='off' aria-label='Search…'>
        </div>
        <button class='menu-item' type='button' data-bs-value='1'>Alabama</button>
        <div class='combobox-no-results d-none'>No results found</div>
      </div>

- `data-bs-name` is what makes it a form control: the plugin inserts a hidden
  input of that name before the toggle and writes the chosen `data-bs-value`
  into it. Never put `name=` on the toggle.
- `data-bs-search='true'` enables filtering, but the search input has to be in
  the markup — the plugin only wires up a `.combobox-search-input` it finds.
- The toggle carries the `id` the label points at, legal because a `<button>` is
  labelable. Use `form.field_id` and `form.field_name`.
- The caret is `<i class='bi bi-chevron-down combobox-caret'></i>`, not
  Bootstrap's inline SVG: the class needs only `flex-shrink` and a rotation, the
  font is loaded, and `<i>` is what every other icon uses.
- The placeholder doubles as the empty label: `Select a <Model>…`, from
  `model_name.human` so a registered acronym survives. An optional association
  says `Optional`, like any other optional field.
- A required association carries `aria-required` on the toggle, not `required`:
  a `<button>` does not take it, and the hidden input that would is written at
  runtime. The requirement is announced, not enforced — the model's validation
  is what rejects a blank.

## Flash messages

- A flash is a Toast, never an inline alert, in a
  `.toast-container.position-fixed.bottom-0.end-0.p-3` at the end of `<body>`.
  `.toast-container` is `position: absolute` in v6, so `position-fixed` is not
  optional — without it the toast scrolls away.
- The variant is the flash key: `theme-success` for a notice, `theme-danger` for
  an alert, a neutral `theme-primary` for a key a host invents. The theme goes
  on the `.toast`.
- The message goes in the *header*, and the body is kept but hidden:

      <div class='toast theme-success' role='alert' aria-live='assertive' aria-atomic='true'>
        <div class='toast-header border-0'>
          <span class='me-auto'>Contact was created.</span>
          <button type='button' class='btn-close' data-bs-dismiss='toast' aria-label='Close'></button>
        </div>
        <div class='toast-body d-none'></div>
      </div>

- That is what tints the whole toast: `.toast-header` takes
  `--bs-theme-bg-subtle` while `.toast` takes the plain body background, so a
  message in the body would sit on white below a colored strip.
- `border-0` removes the header's `border-block-end`, which would rule a line
  under the message with nothing beneath it.
- `me-auto` pushes the X right. Inside a header the close button needs nothing
  else — v6 gives it margins through `.toast-header .btn-close`.
- It autohides, the Toast default. Nothing to declare.
- The wording names the model, never the record: `Contact was created.`,
  `Contact could not be created.`, both from `model_name.human`. Interpolating
  the record prints `#<Contact:0x000000012b6febc8>`.
- Toasts need JavaScript twice over: `.toast:not(.show)` is `display: none`, and
  the autohide timer starts only once shown. The layout imports `Toast` and
  calls `show()` on every `.toast`. `data-bs-dismiss='toast'` needs the
  component loaded too, so the X is dead without it.

## Validation errors

- A rejected `create` redraws the same page with `422`, never a redirect, so the
  fields keep what was typed and the errors sit beside them.
- The failed control gains `is-invalid` and the message follows as
  `<small class='invalid-feedback'>`. Both are needed: Bootstrap reveals the
  feedback with `.is-invalid ~ .invalid-feedback`, so one without the other
  either stays hidden or only reddens a border.
- That selector is a *sibling* one, so the feedback goes after the whole control
  — for a combobox, after the `.menu`, not inside the toggle.
- Nothing writes that markup by hand: `config.action_view.field_error_proc` does
  it for every field a form builder draws — see CLAUDE.md, "Match Bootstrap with
  field_error_proc".
- The combobox is the exception, being a partial rather than a form builder tag,
  so it adds its own `is-invalid` and `.invalid-feedback`.
- The message is the bare reason, sentence-cased: `Must exist`, `Can't be
  blank`. The label already names the attribute.
- A `belongs_to` reports on the association, so a field for `state_id` asks the
  record about both `state_id` and `state` — otherwise a missing state reddens
  nothing.

## Tables

- A `<table>` is `class='table table-hover'`, the hoverable accent rather than
  the striped one. Reach for `.table-striped` only where a table is better
  served by it.
- Always add `.sm:table-stacked`, so rows become stacked blocks once the
  container narrows.
- Cells live in a `_row` partial, one `column` call each, content in a block:

      <%= column header: 'Phone' do %>
        <%= number_to_phone contact.phone %>
      <% end %>

- `column` also takes anything `tag` does — `class:`, `style:` — and passes it
  to both the `th` and the `td`.
- A foreign-key column shows what the record it points at is called, not the id:
  `/locations` heads a column `ZIP code` and fills it with `00501`. The heading
  is the one the form uses, so a table and its form never disagree.
- Those names cost one query per association, not per row, because the index
  eager-loads every `belongs_to` the table can name.
- Every table ends with an `Actions` column, added by `_table` rather than
  `_row` — which is the point: a host writing its own row still gets the column,
  appended after whatever that row defines.
- Where the resource has an `edit` action each row links to it, the link being
  `<i class='bi bi-pencil-square'></i>` with `aria-label='Edit'`, since an icon
  alone says nothing to a screen reader. The column is there either way, empty
  for a resource that only has an index.
- The record arrives under its own name, so a host partial declares
  `<%# locals: (contact:) -%>`. It is rendered once for the header row with that
  local nil, so never assume it is present outside a `column` block.
- A host overrides one table with `app/views/<resources>/_row.html.erb`, which
  wins through the controller's template prefixes — so keep everything
  cell-shaped in that partial and nothing else.
- Stacking needs two more things or it degrades badly: the table must sit in a
  `.table-responsive` wrapper, which is the container query's container, and
  every `<td>` needs `data-cell='<heading>'`, which is where the stacked
  layout's labels come from.
- A table shows every attribute that is not encrypted, one column each.
  Encrypted ones are omitted entirely: ciphertext helps nobody, and decrypting
  into a list leaks it.
- Headings come from `human_attribute_name`, so a host can rename one by
  translating the attribute.
- A `belongs_to` currently shows its raw foreign key — `/counties` renders
  `State` as `1`. Rendering the record instead needs `includes` in the
  controller to stay within the one-count-one-select budget, and that is
  deferred. Do not reach through an association from a view meanwhile.

## Links

- Internal links go through Turbo, so navigation is a fetch and a swap. The
  layout loads Turbo from the CDN.
- Turbo prefetches on `mouseenter`, on by default in Turbo 8 — never add
  `<meta name='turbo-prefetch' content='true'>` to restate it.
- No `data-turbo='false'` or `data-turbo-prefetch='false'` on an internal link.
  Either opts that link out of both behaviors.

## Phone numbers

- A phone shown to a user always goes through `number_to_phone`, so `5552234567`
  reads as `555-223-4567`. Never print the stored digits raw.
- Storage is unaffected: the column still holds ten bare digits.
- In a generic table this keys off the column being named `phone`, which the
  convention guarantees.
- A phone *field* separates as it is typed. Every `<input type='phone'>` carries
  the Stimulus controller that does it:

      data-controller='phone'
      data-action='keydown->phone#down input->phone#input'

- It formats on `connect` too, so a form redrawn after a rejected `create` shows
  the separators rather than the ten digits it was sent.
- Because the value now carries separators, the `pattern` has to accept them or
  the browser refuses to submit what it just helped type:
  `[2-9]\d{2}-[2-9]\d{2}-\d{4}`, the separated form of `NORTH_AMERICAN_PHONES`,
  keeping the rule that an area or exchange code cannot start with 0 or 1. The
  server sees bare digits regardless, since `Phonable` normalizes them away.
- Never put a length validator on a phone: `maxlength` would come from it and
  cut the value at ten characters, three short of `555-555-5555`.
- The `title` says `Please match the format 555-555-5555`, matching the
  placeholder. Where a field has a canonical sample the title uses it rather
  than a shape derived from the pattern, so the two never disagree.

## Times and dates

- A time reads `%b %-d at %I:%M%P %Z` — `Aug 4 at 07:16pm EDT` — in a `<time>`
  tag carrying the machine-readable value:

      <time datetime='2026-08-04T19:16:51-04:00'>Aug 4 at 07:16pm EDT</time>

- `time_tag value, value.strftime(TIME_FORMAT)` builds both halves. Pass the
  text explicitly, or the helper reaches for I18n.
- The `datetime` attribute is `rfc3339`, carrying seconds and offset; the
  visible text drops both.
- Zone comes from `config.time_zone`, so `%Z` reads `EDT` or `EST` by date,
  never `UTC`.

## Pagination

- Paginate with `pagy`, never hand-rolled offsets.
- The page limit is 20, already pagy's default — never pass `limit:` to restate
  it.
- Below the table, in order: `info_tag` for the count, then
  `series_nav :bootstrap` for the links. Both need `<%==`, since they return
  HTML.
- Leave `max_limit` unset. Without it pagy ignores a `?limit=` in the query
  string, so a visitor cannot ask for a page of 100,000 rows.
