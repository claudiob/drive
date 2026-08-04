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
  `class="table table-hover"`. Reach for `.table-striped` only when a specific
  table is better served by it.
- A table of records shows every attribute that is not encrypted, one column
  each — not just the id. Encrypted attributes are omitted entirely: showing
  ciphertext helps nobody, and decrypting it into a list leaks it.
- Column headings come from `human_attribute_name`, so a host app can rename
  one by translating the attribute.

## Pagination

- Paginate with the `pagy` gem, never hand-rolled offsets.
- The page limit defaults to 20.
- Below the table, in this order: `@pagy.info_tag` for the item count, then
  `@pagy.series_nav :bootstrap` for the links. Both need `<%==` rather than
  `<%=`, since they return HTML.
- Pass `limit:` explicitly and leave `max_limit` unset. Without `max_limit`,
  pagy ignores a `?limit=` in the query string, so a visitor cannot ask for a
  page of 100,000 rows.
