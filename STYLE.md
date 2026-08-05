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
- Each field is a `.form-label` and a `.form-control` inside `.mb-3`; the submit
  is `btn btn-solid theme-primary`. In v6 the fill is a separate class from the
  base: `.btn` sizes, `.btn-solid` / `.btn-outline` / `.btn-subtle` fill, and
  `theme-*` colours.
- The field type follows the column, and the rules are in this order: an
  encrypted column is a password field; one named `email` or `color` gets that
  input; a `date` or `time` column gets its own field; everything else is text.
- Encryption wins over the name, so an encrypted `email` is masked rather than
  typed as an email — protecting the value matters more than the keyboard.
- Length and format travel to the browser: `maxlength` from the column limit,
  `pattern` from a format validator with `\A` and `\z` stripped, since an HTML
  pattern is anchored already. A digits-only pattern or an integer column also
  gets `inputmode: 'numeric'`.
- A `datetime` column falls through to a text field. Nothing needs one yet;
  it is the next gap to fill.

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
