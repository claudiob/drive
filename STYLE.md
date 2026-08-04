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
- Still current from v5: `.container`, `.table`, `.table-responsive`, and
  `data-bs-theme="light|dark"` for color modes — though `color-scheme: light
  dark` on `:root` follows the system by default, so most pages need no theme
  attribute at all.
- The gem ships `app/views/layouts/application.html.erb` for hosts that have
  none, wired up per the CDN Quickstart: Geist and Geist Mono from Google
  Fonts, then Bootstrap's CSS, with the JS bundle as a module before `</body>`.

## Tables

- A `<table>` defaults to the hoverable accent, not the striped one:
  `class='table table-hover'`. Reach for `.table-striped` only when a specific
  table is better served by it.
- Always add `.sm:table-stacked`, so rows become stacked blocks once the
  container gets narrow.
- Cells live in a `_row` partial, rendered with `heading: true` for the header
  row and once per record below it. A host app overrides one table by defining
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

## Pagination

- Paginate with the `pagy` gem, never hand-rolled offsets.
- The page limit is 20, which is already pagy's own default — so never pass
  `limit:` to restate it.
- Below the table, in this order: `info_tag` for the item count, then
  `series_nav :bootstrap` for the links. Both need `<%==` rather than `<%=`,
  since they return HTML.
- Leave `max_limit` unset. Without it pagy ignores a `?limit=` in the query
  string, so a visitor cannot ask for a page of 100,000 rows.
