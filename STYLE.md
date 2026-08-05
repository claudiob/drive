# Design Guidelines

**Scope:** how the pages this gem serves look and are marked up. `CLAUDE.md` is
the authority for code style; this file is the authority for design. Read it
before writing or editing any layout, view or partial.

## Bootstrap 6 Alpha for all markup

- Every layout, view and partial follows Bootstrap 6 Alpha conventions.
  Reference: https://v6-dev--twbs-bootstrap.netlify.app/llms-full.txt
- Check class names against those docs rather than recalling Bootstrap 5. v6
  renames and removes plenty: responsive utilities are prefixed
  (`md:col-6`, not `col-md-6`), `.bg-light` / `.bg-dark` are gone in favour of
  the `.bg-1` / `.bg-2` scale, and `.text-body-secondary` is now `.fg-2`.
- Page wrappers use `.container-fluid`, never `.container`. A table wants the
  whole width on a desktop, not a centred column with margins either side.
- Still current from v5: `.container-fluid`, `.table`, `.table-responsive`, and
  `data-bs-theme="light|dark"` for color modes — though `color-scheme: light
  dark` on `:root` follows the system by default, so most pages need no theme
  attribute at all.
- The gem ships `app/views/layouts/application.html.erb` for hosts that have
  none, wired up per the CDN Quickstart: Geist and Geist Mono from Google
  Fonts, then Bootstrap's CSS, with the JS bundle as a module before `</body>`.

## The navbar

- Every page opens with a navbar holding a breadcrumb, then `yield :actions`,
  both to the left.
- The breadcrumb ends at the current page, and that last item is *not* a link:
  a `<span class='breadcrumb-link active'>` inside an
  `<li class='breadcrumb-item' aria-current='page'>`. Bootstrap's own example
  uses an `<a>` there; we deliberately do not.
- Earlier items are links and carry the resource icon, separated by empty
  `<li class='breadcrumb-divider'>` elements — v6 draws the chevron from that
  element, not from a CSS `content` string on `::before` as v5 did.
- An index has one item, its own name. Any other page links back to the index
  first and then names itself: `/counties/new` reads `Counties` as a link, then
  `New county` as plain text.
- A view contributes buttons with `content_for :actions`; the layout only
  yields. Nothing else belongs in the navbar.
- A breadcrumb link and its sidebar twin line up vertically, which constrains
  both. The `<nav class='navbar'>` carries no horizontal margin or padding of
  its own, so both columns reduce to `container-fluid` (0.75rem) plus a link
  padding of 0.75rem — the sidebar's own 0.75rem container padding is cancelled
  by `.row`'s negative margin. Adding `px-*` or `mx-*` to the navbar shifts the
  breadcrumb out of line by exactly that much.
- `.breadcrumb-link` needs `gap-2`. Both link types are flex, but only
  `.nav-link` ships a `gap`, and a whitespace-only text node is not a flex item
  — so without it the breadcrumb's icon and text would touch while the
  sidebar's sit 0.5rem apart.
- An index offers `Add <resource>` only when there is somewhere to go: the
  `new` route has to be drawn *and* the controller has to implement the action,
  or the button would 404 or raise. Its classes are
  `btn theme-primary btn-sm btn-outline ms-3`.

## Icons on resource links

- A link to a resource is preceded by a Bootstrap Icon, using the `<i>` form:
  `<i class='bi bi-person-rolodex'></i> Contacts`. The layout loads
  `bootstrap-icons@1.13.1`.
- Pick the icon by the displayed title, from this map. It is duplicated in
  `lib/recourse/icons.rb`, which is what the code reads — change both together.
- An unlisted title falls back to `circle`, so a column of links stays aligned.
  Add a real entry rather than leaving the fallback in place.

      'Agents' => 'robot', 'Answers' => 'question-circle', 'Apps' => 'window',
      'Assessments' => 'clipboard-check', 'Bookings' => 'calendar-check',
      'Brands' => 'buildings', 'Campaigns' => 'megaphone',
      'Contacts' => 'person-rolodex', 'Contract' => 'file-earmark-check',
      'Conversations' => 'chat-dots', 'Counties' => 'map', 'CRM' => 'plugin',
      'Echoes' => 'soundwave', 'Episodes' => 'collection-play',
      'Evaluations' => 'speedometer2', 'Franchises' => 'shop', 'Home' => 'house',
      'Logout' => 'box-arrow-right', 'Markets' => 'pin-map',
      'Offer questions' => 'gift', 'Optimizations' => 'sliders',
      'Platforms' => 'plugin', 'Profile' => 'person-circle',
      'Prompts' => 'terminal', 'Providers' => 'briefcase',
      'Satisfaction questions' => 'emoji-smile', 'Searches' => 'search',
      'Settings' => 'gear', 'Sources' => 'signpost', 'Specialties' => 'award',
      'Specialty matches' => 'award', 'States' => 'geo',
      'Verticals' => 'bar-chart', 'ZIPs' => 'geo-alt-fill'

- `Home` maps to `house`: Bootstrap Icons has no `home`, so that entry would
  have rendered an empty box.
- Icons go on *links*. The breadcrumb's current-page item is not a link, so it
  carries no icon.

## The sidebar

- Below the navbar, an `<aside>` sits to the left of the content holding a
  vertical `ul.nav.flex-column` of links — one per resource `recourses` drew.
- The order is the order `config/routes.rb` declares them, never sorted.
- The entry for the page being shown is `nav-link active` with
  `aria-current='page'`. It is matched on the controller, not on the URL, so
  `/contacts?page=2` still marks Contacts active.
- A resource appears only if its `index` action is routed. `recourses :drafts,
  only: :new` draws no index, so it gets no link rather than a broken one.
- Layout is `.row` with `aside.col-auto` and `main.col`, inside the page's
  `.container-fluid`.
- The aside's border runs to the bottom of the window. That takes a chain of
  three: `body.d-flex.flex-column.min-vh-100`, then
  `.container-fluid.flex-grow-1.d-flex`, then `.row.flex-grow-1`. The aside
  stretches because `.row` is a flex container and Bootstrap leaves
  `align-items` unset, so items default to `stretch`.
- `min-height` rather than `height`, so short pages fill the window without a
  scrollbar and long ones still scroll.

## Forms

- The gem serves `new.html.erb`: it sets `:title` to `New <resource>` and
  renders the `form` partial, passing the record explicitly under its own name.
- The form is `form_with model:` plus one field per *editable* column — every
  column except `id`, `created_at` and `updated_at`. Encrypted columns are
  editable even though the table will not display them.
- Each field is a `.form-label` and a `.form-control` inside
  `.mb-3.lg:col-6`, and the whole set sits in one `.row`. Two fields to a row on
  a large viewport, stacked below it — a name or a phone number needs nowhere
  near the full width of a page, so a form of full-width inputs reads as a
  column of empty space.
- The submit is `btn btn-solid theme-primary`. In v6 the fill is a separate class
  from the base: `.btn` sizes, `.btn-solid` / `.btn-outline` / `.btn-subtle`
  fill, and `theme-*` colours.
- A field whose attribute is not required carries `placeholder='Optional'`.
  Required is judged by the model's validators, not by `null: false` — and a
  `belongs_to` validates the association, so `state_id` counts as required
  through `:state`.
- A required attribute also gets a required *field*: `required` on the input, so
  the browser turns the form back before the server ever sees it. It is the same
  judgement the placeholder makes, from the same validators — the two are
  readings of one fact and never disagree.
- Worth knowing before there is an `edit` action: a required encrypted attribute
  is a required password field, and a password field renders empty, so editing a
  record would demand the value be retyped. Revisit the rule then, not now.
- A required field shows the shape it expects instead: `555-555-5555` for a
  phone, `michael@example.com` for an email. Every other required field has no
  placeholder, since there is nothing useful to show.
- An explicit `type:` picks the sample on its own, required or not. `field :email,
  type: :email` on an optional column shows `michael@example.com` rather than
  `Optional`: the caller has said what the field is, and the sample is the more
  useful of the two hints.
- The field list is a `fields` partial of its own, so a host app can replace the
  fields without rewriting `form_with` or the submit button. It renders one
  `field` per editable column; a host writes the calls it wants by hand.
- `field` takes the column name and two options: `label:` for the heading and
  `type:` for the input. `field :phone, type: :phone` beats every rule below,
  including the encrypted-column one — an explicit type is an instruction.
- The field type otherwise follows the column, and the rules are in this order: a
  foreign key is a combobox; an encrypted column is a password field; one named
  `email` or `color` gets that input; a `date`, `time` or `datetime` attribute
  gets its own field, the last of those as `datetime-local`; everything else is
  text.
- Encryption wins over the name, so an encrypted `email` is masked rather than
  typed as an email — protecting the value matters more than the keyboard.
- Length, format and numericality travel to the browser, and all three are read
  from the model's *validators*, never from the column: `maxlength` and
  `minlength` from a length validator's `maximum`, `minimum` or `is`, `pattern`
  from a format validator with `\A` and `\z` stripped since an HTML pattern is
  anchored already, and `inputmode: 'numeric'` from a numericality validator or
  a digits-only pattern.
- Always pass `size: nil`. Rails mirrors `maxlength` into `size`, and a
  five-character box for a ZIP code undoes the width rule above.
- Which input a `date`, `time` or `datetime` gets is the one thing no validator
  can say, so it comes from `type_for_attribute` — the model's own attribute
  type, which an `attribute` override still governs — and not from
  `columns_hash`.

## Comboboxes for foreign keys

- A form never asks for a foreign key in a text field. `state_id` is a Bootstrap
  combobox listing each `State` by `name`, in the "Search menu items" form, so a
  list of fifty stays usable.
- The markup is the toggle followed by its `.menu` **sibling** — the plugin finds
  the menu with `SelectorEngine.next`, so anything between them breaks it:

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
  into it. Never put `name=` on the toggle itself.
- `data-bs-search='true'` enables filtering, but the search input has to be in
  the markup — the plugin only wires up a `.combobox-search-input` it finds.
- The toggle carries the `id` the label points at, which is legal because a
  `<button>` is a labelable element. Use `form.field_id` and `form.field_name`
  rather than spelling either out.
- Bootstrap's example uses an inline SVG caret; ours is
  `<i class='bi bi-chevron-down combobox-caret'></i>`. The class only needs
  `flex-shrink` and a rotation, the icon font is already loaded, and the `<i>`
  form is what every other icon on the page uses.
- The placeholder doubles as the empty label: `Select a <Model>…`, from
  `model_name.human` so a registered acronym survives. An optional association
  says `Optional` instead, like any other optional field.
- A required association carries `aria-required` on the toggle rather than
  `required`. The toggle is a `<button>`, which `required` does not apply to, and
  the hidden input that would take it is not in the markup — the plugin writes it
  at runtime. So the requirement is announced, not enforced: the model's
  validation is still what rejects a blank.

## Validation errors

- A rejected `create` redraws the same page with `422`, never a redirect, so the
  fields keep what was typed and the errors sit beside them.
- The control that failed gains `is-invalid`, and the message follows it as
  `<div class='invalid-feedback'>`. Both are needed: Bootstrap reveals the
  feedback with `.is-invalid ~ .invalid-feedback`, so a feedback div on its own
  stays hidden and an `is-invalid` on its own only reddens the border.
- Because that selector is a *sibling* one, the feedback goes after the whole
  control — for a combobox, after the `.menu`, not inside the toggle.
- The message is the bare reason, sentence-cased: `Must exist`, `Can't be blank`.
  The label above it already names the attribute, so a full message would repeat
  it.
- A `belongs_to` reports its error on the association, so a field for `state_id`
  asks the record about both `state_id` and `state` — otherwise a missing state
  reddens nothing.

## Tables

- A `<table>` defaults to the hoverable accent, not the striped one:
  `class='table table-hover'`. Reach for `.table-striped` only when a specific
  table is better served by it.
- Always add `.sm:table-stacked`, so rows become stacked blocks once the
  container gets narrow.
- Cells live in a `_row` partial, one `column` call each, with the content in a
  block:

      <%= column header: 'Phone' do %>
        <%= number_to_phone contact.phone %>
      <% end %>

- `column` also takes anything `tag` does — `class:`, `style:` — and passes it
  to both the `th` and the `td`.
- The record arrives under its own name, `contact:` for contacts, so a host
  partial declares `<%# locals: (contact:) -%>`. It is rendered once for the
  header row with that local set to nil, so never assume it is present outside
  a `column` block.
- A host app overrides one table by defining
  `app/views/<resources>/_row.html.erb`, which wins through the controller's
  template prefixes — so keep everything cell-shaped in that partial and
  nothing else.
- Stacking needs two more things, or it degrades badly. The table must sit
  inside a `.table-responsive` wrapper, which is the container query's
  container. And every `<td>` needs `data-cell='<heading>'` — that is where the
  labels in the stacked layout come from, so without it a narrow screen shows
  values with nothing naming them.
- A table of records shows every attribute that is not encrypted, one column
  each — not just the id. Encrypted attributes are omitted entirely: showing
  ciphertext helps nobody, and decrypting it into a list leaks it.
- Column headings come from `human_attribute_name`, so a host app can rename
  one by translating the attribute.
- A `belongs_to` currently shows its raw foreign key — `/counties` renders the
  `State` column as `1`. Rendering the associated record instead needs
  `includes` in the controller to stay within the one-count-one-select budget,
  and that work is deferred. Do not reach through an association from a view in
  the meantime.

## Links

- Internal links go through Turbo, so navigation is a fetch and a swap rather
  than a full page load. The layout loads Turbo from the CDN.
- Turbo prefetches a link on `mouseenter`, so a page is already on its way
  before the click lands. This is on by default in Turbo 8 — never add
  `<meta name='turbo-prefetch' content='true'>` to restate it.
- Do not put `data-turbo='false'` or `data-turbo-prefetch='false'` on an
  internal link. Either one opts that link out of both behaviours.

## Phone numbers

- A phone number shown to a user always goes through `number_to_phone`, so
  `5552234567` reads as `555-223-4567`. Never print the stored digits raw.
- Storage is unaffected: the column still holds ten bare digits, as `CLAUDE.md`
  requires. The formatting is for reading only.
- In a generic table this keys off the column being named `phone`, which is
  safe because that convention guarantees the name.

## Times and dates

- A time on a page reads `%b %-d at %I:%M%P %Z` — `Aug 4 at 07:16pm EDT` —
  wrapped in a `<time>` tag carrying the machine-readable value:

      <time datetime='2026-08-04T19:16:51-04:00'>Aug 4 at 07:16pm EDT</time>

- Rails' `time_tag` builds both halves: `time_tag value,
  value.strftime(TIME_FORMAT)`. Pass the text explicitly, or the helper reaches
  for I18n instead.
- The `datetime` attribute is `rfc3339`, so it carries seconds and the offset.
  The visible text drops both; the attribute is what a machine reads.
- Zone comes from `config.time_zone`, so `%Z` reads `EDT` or `EST` depending on
  the date, never `UTC`.

## Pagination

- Paginate with the `pagy` gem, never hand-rolled offsets.
- The page limit is 20, which is already pagy's own default — so never pass
  `limit:` to restate it.
- Below the table, in this order: `info_tag` for the item count, then
  `series_nav :bootstrap` for the links. Both need `<%==` rather than `<%=`,
  since they return HTML.
- Leave `max_limit` unset. Without it pagy ignores a `?limit=` in the query
  string, so a visitor cannot ask for a page of 100,000 rows.
