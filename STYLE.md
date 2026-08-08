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
  none: Bootstrap's CSS in the head, the JS bundle as a module before `</body>`,
  and Geist and Geist Mono from Google Fonts.
- Bootstrap is *vendored*, not linked. `vendor/recourse/` holds
  `bootstrap.min.css`, `bootstrap.bundle.min.js`, `bootstrap-icons.min.css` and
  the two icon fonts, and the layout asks for `/recourse/…`. A CDN that moves or
  goes down would otherwise take every page's styling with it, and the Bootstrap
  6 CSS is served from a preview host rather than a release one.
- The icon fonts are not optional extras. `bootstrap-icons.min.css` reaches for
  `fonts/bootstrap-icons.woff2` beside itself, so vendoring the CSS alone leaves
  every icon a blank box.
- The engine serves them with `Rack::Static`, since a host may run no asset
  pipeline at all — see CLAUDE.md, "Vendor what a page cannot render without".

## The navbar

- Every page opens with a navbar holding a breadcrumb, then `yield :actions`,
  both to the left, and `yield :search` pushed to the right by the form's own
  `ms-auto`.
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
- A view contributes buttons with `content_for :actions` and its search form with
  `content_for :search`; the layout only yields. Nothing else belongs in the
  navbar.
- Both are the *host's* to place. The gem never renders either where it decides:
  a host that writes its own layout and yields neither gets no buttons and no
  search box, the same way it gets no styling until it links the stylesheets.
  The layout the gem ships is what a host's own layout is modelled on, which is
  why the dummy app — having none of its own — shows the search in the navbar.
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
- Every control in the navbar is the small size, since it shares a line with a
  breadcrumb: `btn-sm` on a button, `form-control-sm` on a field, and
  `form-control-sm` on a combobox toggle, which is a `<button>` wearing
  `.form-control` and takes the same class. The combobox partial gets there
  through a `small:` local, so the same partial draws a full-size one inside a
  form and a small one in the navbar.
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
      'Jobs' => 'hammer', 'Locations' => 'geo-alt', 'Logout' => 'box-arrow-right',
      'Markets' => 'pin-map', 'Messages' => 'chat-text',
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
- Layout is `.row` with `aside.col-12.md:col-auto` and `main.col-12.md:col`,
  inside the page's `.container-fluid`. Below 768px each is a full-width row of
  its own, so the sidebar sits under the navbar and the content under that;
  from 768px they are the two columns again, unchanged.
- Stacked, the links run across rather than down: the `ul` is `nav md:flex-column`,
  and a plain `.nav` is a wrapping flex row.
- The rule between the sidebar and what it sits against follows it around —
  `border-block-end` while it is a band under the navbar, `border-inline-end`
  once it is a column beside the content. v6 generates no responsive border
  utilities, so `.recourse-sidebar` writes both out in the layout's `<style>`
  rather than the aside carrying `border-end`.
- The aside's border runs to the bottom of the window. That takes a chain of
  three: `body.d-flex.flex-column.min-vh-100`, then
  `.container-fluid.flex-grow-1.d-flex`, then `.row.flex-grow-1`. The aside
  stretches because `.row` is a flex container and Bootstrap leaves
  `align-items` unset, so items default to `stretch`.
- `min-height` rather than `height`, so short pages fill the window without a
  scrollbar and long ones still scroll.
- Every entry answers to a letter of its own title, held with Option: `Contacts`
  to C, `Counties` — declared after it — to O, since C was taken. The letter is
  the first one in the title nothing above it has claimed, which is what makes
  the hint below able to point at it rather than at a number nobody can guess.
- Holding Option marks that letter in place: `C` in `Contacts` and `o` in
  `Counties` gain a weight and an underline. Marked rather than bracketed —
  `[C]ontacts` would shift every entry two characters wide the moment the key
  went down, and a sidebar that jumps is a worse hint than one that does not.
  The bracketed form is two commented-out rules in the layout for whoever wants
  it.
- Option, not Control or Command: both of those are spoken for by the browser and
  the system — Control+C and Command+C are copy — while Option is what a
  browser's own `accesskey` reaches for on most platforms.
- The marked title is wrapped in one element, and that is not decoration.
  `.nav-link` is a flex container with a `gap`, so a bare `<span>` around the
  letter would make three flex items of `C`, `o` and `unties` and put the gap
  between each — the entry would read `C o unties`. One wrapper is one item, and
  inside it the word is an ordinary word again. The same trap as the breadcrumb's
  `gap-2` above, from the other side.
- The key is matched on `event.code`, not `event.key`. On a Mac, Option+c is `ç`,
  so the character produced says nothing about which key was pressed.
- The link is `click`ed rather than followed by assigning a location, so the
  visit is Turbo's like any other, and the `accesskey` attribute is deliberately
  not set: the browser would activate the same link a second time.

## Forms

- The gem serves `new.html.erb`: it sets `:title` to `New <resource>` and
  renders the `form` partial, passing the record explicitly under its own name.
- It serves `edit.html.erb` the same way, titled after the record instead — the
  value of whatever its model's `recourse_label` names, so a market reads
  `Chicago`. Both render the *same* `form` partial, so a host that writes one
  `_fields.html.erb` gets it on both pages and never writes a second.
- After a rejected update the title shows what was typed, not what is stored,
  because the record already carries the submitted values. Blanking the label
  blanks the title.
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
- A field with a `pattern` also carries a `title` showing the shape it wants:
  `\d{5}` gives `title='Please match the format 00000'`. Without one the browser
  says only that the value does not match, which tells nobody what would. The
  example is read off the pattern — `\d` becomes a digit, `\w` a letter, a bracket
  class its first character, and `{n}` repeats — so the phone's
  `[2-9]\d{2}[2-9]\d{6}` reads as `2002000000`.
- Always pass `size: nil`. Rails mirrors `maxlength` into `size`, and a
  five-character box for a ZIP code undoes the width rule above.
- Which input a `date`, `time` or `datetime` gets is the one thing no validator
  can say, so it comes from `type_for_attribute` — the model's own attribute
  type, which an `attribute` override still governs — and not from
  `columns_hash`.

## Comboboxes for foreign keys

- A form asks for a foreign key one of two ways, and which one is the label's
  decision. Where the label has a *length validator* it is short enough to type,
  so the field asks for the value; otherwise it is a combobox to pick from.
- A typed reference names both: the label reads `ZIP code`, not `ZIP`, since a
  code is what the field wants. It takes the shape of that attribute —
  `maxlength`, `minlength`, `pattern`, `title`, `inputmode` — from the model the
  attribute belongs to, but takes *required* from the association that needs it,
  which is the page's model and not the other one's.
- This is what keeps a form from being enormous. `/locations/new` was 3.3 MB when
  its ZIP was a combobox of 40,965 options; typing the code instead makes it
  6.4 KB. A combobox is right for fifty states and wrong for forty thousand ZIPs.
- A value that matches no record leaves the foreign key nil, so `belongs_to`
  reports `Must exist` beside the field, and the field keeps what was typed. That
  value comes from `params`, not from the record — nothing was ever assigned to it.
- `state_id` is still a Bootstrap combobox listing each `State` by `name`, in the
  "Search menu items" form, so a list of fifty stays usable.
- What each option reads is the model's own `recourse_label` — `name` by default,
  `code` for a ZIP, `email` for an Agent. See CLAUDE.md, "Every model says how it
  is labelled".
- The menu holds every row, so it is only as usable as the table is small. The
  ZIP combobox on `/locations/new` is 40,965 options and 3.3 MB of HTML: the
  search box finds one instantly, but the page pays for all of them up front.
  Bootstrap filters what is already in the DOM, so there is no cheaper option
  short of a server-side search.
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
- That input carries an X inside its right edge once there is anything to clear,
  and nothing before then. A menu of fifty states filtered down to one is two
  keystrokes from being useful again, and a backspace-until-empty is a poor way
  to ask:

      <div class='combobox-search' data-controller='clear'>
        <input type='text' class='form-control combobox-search-input' placeholder='Search…'
               autocomplete='off' aria-label='Search…'
               data-clear-target='input' data-action='input->clear#toggle'>
        <button type='button' class='combobox-search-clear d-none' aria-label='Clear search'
                data-clear-target='button' data-action='clear#clear'>
          <i class='bi bi-x-lg'></i>
        </button>
      </div>

- The button starts `d-none` and the `clear` controller shows it on `input`,
  since whether a field has anything in it is not something the server can know:
  the menu is cached, and the same markup is served to a field being typed into
  and one that was never touched.
- Emptying the field is not enough on its own. Bootstrap filters the menu's rows
  on the field's `input` event, so the controller dispatches one after clearing,
  or the rows stay filtered to a term that is no longer there. It then puts the
  caret back in the field, which is where someone who cleared a search is about
  to type.
- The X is positioned rather than laid out: `.combobox-search` is the relative
  container, the input reserves room with `padding-inline-end`, and the button
  sits in it. A flex row instead would put the button *beside* the field, which
  is a different control — Bootstrap's own search box has nothing there.
- Its `display` is set through `.combobox-search-clear:not(.d-none)`, never on
  the element itself. v6's display utilities carry no `!important` — `.d-none` is
  a plain `display:none` — so any rule of ours with the same specificity and a
  later position beats it, and a `display: flex` on the button showed an X over
  every empty field. Anything the gem styles that a class is meant to hide needs
  the same treatment.
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

## Flash messages

- A flash is a Toast, never an inline alert, in a
  `.toast-container.position-fixed.bottom-0.end-0.p-3` at the end of `<body>`.
  `.toast-container` is `position: absolute` in v6, so `position-fixed` is not
  optional — without it the toast scrolls away with the page.
- The variant is the flash key: `toast theme-success` for a notice, `toast
  theme-danger` for an alert, and a neutral `theme-primary` for a key a host
  invents. The theme goes on the `.toast` itself.
- The message goes in the *header*, and the body is kept but hidden:

      <div class='toast theme-success' role='alert' aria-live='assertive' aria-atomic='true'>
        <div class='toast-header border-0'>
          <span class='me-auto'>Contact was created.</span>
          <button type='button' class='btn-close' data-bs-dismiss='toast' aria-label='Close'></button>
        </div>
        <div class='toast-body d-none'></div>
      </div>

- That is what tints the whole toast. `.toast-header` takes its background from
  `--bs-theme-bg-subtle` while `.toast` itself takes the plain body background, so
  a message in the body would sit on white below a coloured strip. With the body
  hidden the toast *is* the header, and the theme colours all of it.
- `border-0` removes the header's `border-block-end`, which would otherwise rule a
  line under the message with nothing beneath it.
- `me-auto` on the message is what pushes the X to the right. Inside a header the
  close button needs nothing else: v6 gives it margins through
  `.toast-header .btn-close`, which a headerless toast would have had to supply
  itself.
- It autohides, which is the Toast default — nothing to declare.
- The wording names the model, never the record: `Contact was created.` and
  `Contact could not be created.`, both from `model_name.human`. Interpolating the
  record instead prints `#<Contact:0x000000012b6febc8>`, because Active Record
  leaves `to_s` as Object's.
- Toasts need JavaScript twice over. `.toast:not(.show)` is `display: none`, so
  one has to be shown, and the autohide timer only starts when it is. The layout
  imports `Toast` from the bundle and calls `show()` on every `.toast` it finds.
  `data-bs-dismiss='toast'` needs the component loaded too, so the X is dead
  without it.

## Validation errors

- A rejected `create` redraws the same page with `422`, never a redirect, so the
  fields keep what was typed and the errors sit beside them.
- The control that failed gains `is-invalid`, and the message follows it as
  `<small class='invalid-feedback'>`. Both are needed: Bootstrap reveals the
  feedback with `.is-invalid ~ .invalid-feedback`, so a feedback element on its
  own stays hidden and an `is-invalid` on its own only reddens the border.
- Because that selector is a *sibling* one, the feedback goes after the whole
  control — for a combobox, after the `.menu`, not inside the toggle.
- Nothing writes that markup by hand. `config.action_view.field_error_proc` does
  it for every field a form builder draws — see CLAUDE.md, "Match Bootstrap with
  field_error_proc".
- The combobox is the exception, because it is a partial rather than a form
  builder tag, so `field_error_proc` never sees it. It adds its own `is-invalid`
  and its own `.invalid-feedback`.
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
- A foreign-key column shows what the record it points at is called, not the id
  that points at it: `/locations` heads a column `ZIP code` and fills it with
  `00501`. The heading is the one the form uses for the same column, so a table
  and its form never disagree about what a column is.
- Those names cost one query per association rather than one per row, because the
  index eager-loads every `belongs_to` the table can name. Twenty locations still
  cost five queries.
- Every table ends with an `Actions` column, and `_table` adds it rather than
  `_row`. That is the whole point of putting it there: a host that writes its own
  row still gets the column, appended after whatever columns that row defines, so
  `/contacts` reads `Name | Phone | Created at | Actions`.
- Where the resource has an `edit` action each row links to it, and the link's
  content is the `<i class='bi bi-pencil-square'></i>` icon rather than the word.
  It carries `aria-label='Edit'`, since an icon alone says nothing to a screen
  reader.
- The column is there either way, empty for a resource that only has an index.
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
  each. Encrypted attributes are omitted entirely: showing ciphertext helps
  nobody, and decrypting it into a list leaks it.
- The primary key is omitted too. An id is how a row is addressed, not something
  to read about it, and a column of them is a column of noise next to the name
  the row is actually known by.
- `created_at` and `updated_at` come last, in that order, whichever way round the
  schema declares them — they are what Rails maintains rather than what the
  record is about, and a reader scanning a table wants its subject first. They
  still precede the `Actions` column, which `_table` appends after every column a
  row defines.
- Column headings come from `human_attribute_name`, so a host app can rename
  one by translating the attribute.
- Column headings that can be sorted are links, which the section below covers.

## Sorting, searching and filtering

- A heading that can be sorted is drawn with `sort_header(name)` in place of a
  bare title, inside the usual `column` call:

      <%= column header: sort_header('name') do %>
        <%= resource_cell record, 'name' %>
      <% end %>

  It draws a link only on the header pass — `@recourse_headers` — and the plain
  title on every other, which is what keeps a `<td>`'s `data-cell` readable text
  rather than a serialized `<a>`; `column` reads the same value for the `<th>`
  and for every `<td>`.
- It is named apart from Ransack's `sort_link`, which it calls. Taking that name
  would take the helper itself away from every view these controllers render,
  since ours would answer first — so a host writing `sort_link @q, :name, 'Name'`
  in a partial of its own still gets Ransack's, unchanged.
- The link passes `hide_indicator: true` and draws its own caret instead —
  `bi bi-caret-up-fill` ascending, `bi bi-caret-down-fill` descending — with no
  caret at all on a column nobody sorted by, so an arrow never claims an order
  that is not in force.
- It also passes `page: nil`, so clicking a heading restarts the table at its
  first page. Ransack's own link already carries every other `q` parameter, so
  sorting keeps whatever search or filter was in force.
- `search_form` renders `recourses/_search`, or nothing where the model's
  `recourse_searchable?` is false. The index puts it in `content_for :search`
  and never draws it in place, so where it appears is the layout's decision and
  not the table's. It is contributed outside the empty-table branch, so a filter
  that matched nothing can still be cleared from the page it emptied.
- The form is a GET `search_form_for` in a `.recourse-search` row: `d-flex`,
  `align-items-center`, `justify-content-end`, `gap-2`, `ms-auto`, and
  `flex-wrap md:flex-nowrap`. One line from 768px up, since it shares the navbar
  with a breadcrumb and a row that wrapped there would push the navbar's height
  around as a page gained a filter — and free to wrap below that, where a line of
  three filters and a search box has nowhere left to shrink to.
- It takes the width the breadcrumb and the buttons leave, up to `48rem`, and
  gives it back as the viewport narrows. The search box is what absorbs the
  difference — `flex: 2 1 16rem` with an `8rem` floor, against `flex: 0 1 10rem`
  for a combobox toggle — so the field someone types into is the widest thing in
  the row on a large viewport, and the filters keep their labels readable rather
  than growing into space nobody reads.
- That toggle rule is not decoration. `.combobox-toggle` is `width: 100%`, which
  for a flex item means the width of the whole form, so without a basis of its own
  every filter would fight the search box for the entire row.
- Wrapped, the form carries `mt-2 md:mt-0`: the navbar wraps it onto a line of its
  own under the breadcrumb and the buttons, and Bootstrap's flex container has no
  row gap, so the two rows would otherwise touch.
- Below 768px every control in it is `flex: 1 1 100%` and the form's `max-width`
  comes off, so each filter and the search box is a full-width row of its own.
  Once they are stacked there is no second control beside them to share a line
  with, and a half-width box in a column of them reads as unfinished. Both rules are in the layout's
  `<style>`, since neither is a width Bootstrap has a utility for. It
  carries the table's current sort as a `hidden_field_tag 'q[s]'`, without which
  searching would silently reorder the table back to the model's own default.
- The search box is a Bootstrap 6 adorned control: an icon and an input inside
  one bordered box, rather than two elements butted against each other:

      <div class='form-control form-control-sm form-adorn d-flex w-auto'>
        <span class='form-adorn-icon'><i class='bi bi-search'></i></span>
        <%= form.search_field field, class: 'form-ghost', placeholder: prompt,
                                     aria: { label: prompt } %>
      </div>

- Filters reuse "Comboboxes for foreign keys" with `multiple: true`, one per
  `filter_fields` entry whose predicate names a `belongs_to`. A multiple menu
  item ends with its own check, shown only once picked:

      <button class='menu-item selected' type='button' data-bs-value='1' aria-selected='true'>
        Alabama<i class='bi bi-check menu-item-check'></i>
      </button>

  Bootstrap only reveals that check for `.selected > .menu-item-check`, so the
  class and the icon travel together. `data-bs-multiple='true'` on the toggle
  is what tells the plugin to write '2 selected' into it, instead of
  replacing the toggle's text with whatever was picked last.
- A multiple menu opens with `All <resources>` above a `.menu-divider` — `All
  states`, `All sources` — which is the filter's own empty state named, and the
  way back to it without unticking whatever was ticked. It is always there, so
  the menu never changes shape as it is used.
- Two things about that entry are load-bearing. It carries no `data-bs-value`,
  which is exactly what Bootstrap's click handler matches on
  (`.menu-item[data-bs-value]`), so the plugin passes it by and the click is
  ours. And it never carries `.selected`, which the plugin counts on *any*
  element in the menu — a checked-looking `All states` would be submitted as
  `undefined` alongside the real values.
- Clicking it clicks each selected option in turn, rather than emptying the
  hidden input by hand. The plugin has no method for this, and driving its own
  path is what keeps the hidden input, the toggle's text and its events its
  business. The submits that follow are coalesced to one, or emptying a filter of
  four would ask the server for four tables.
- A foreign key is offered a filter only while the model it points at is short
  enough to list — `recourse_listable?`, which is 100 rows. A menu is a control
  while every row fits in one and a page of HTML nobody reads past that: fifty
  states are a list, 3,144 counties and 40,965 ZIPs are not. Naming that
  predicate in `filter_fields` with a `scope:` draws a filter anyway, over
  whatever narrower relation the scope names.
- Dropping the county menu took `/zips` from 496KB to 22KB. That page was the
  combobox.
- No foreign key's heading is a sort link, whichever control narrows it. Its cell
  shows a label from another table and the id underneath is not the order that
  label reads in: `/locations` sorted by `zip_id` is ZIP codes in the order the
  ZIPs happened to be created, and `/counties` sorted by `state_id` is states in
  the order they were seeded. A heading that claims to sort by what it shows has
  to sort by what it shows.
- What that foreign key gets instead is a place in the search box, its label
  ORed in with the model's own columns: `/locations` searches `zip_code_cont`,
  `/zips` searches `code_or_county_name_cont`. One control replaces the other, so
  a page never loses the ability to narrow by a ZIP or a county — it types the
  word instead of picking it. The label only has to be a word for this: a `cont`
  against an id or a date matches nothing, so a long table labelled by one is
  left with neither control.
- A form asks a different question of the same foreign key, and the two answers
  can differ. A field asks whether the label can be *typed* — a length validator,
  per "Comboboxes for foreign keys" — while a filter asks whether the table can
  be *listed*. A county name has no length to validate, so the form would still
  draw a menu of 3,144 where the filter no longer does.
- The combobox fragment is keyed `[recourses, multiple, selected]`, not just
  the relation: the same relation drawn as a single form combobox and as a
  multiple filter is different markup, and the same menu with a different
  selection is too.
- The table fragment is `cache_if params[:q].blank?, recourses`, so a sorted
  or filtered table is always drawn live rather than cached. Two requests can
  build the identical relation and still want different headings — only one
  of them clicked a heading to get it — so caching on the relation alone
  would serve one request's headings to the other.
- Typing in the search box submits the form after 300ms of quiet, through the
  `search` Stimulus controller registered beside `phone` in the layout:
  `data-action='input->search#submit'`.
- The caret goes back into that box when a submit replaced the whole page, which
  with the results frame in place means only when Turbo is absent. The controller
  cannot
  hold that intent itself — it is torn down with the page it belongs to — so a
  variable in the *module* records it, which the visit does not reload, and the
  next controller consumes it in `connect`. It skips a cached preview, since the
  real render connects again afterwards and is the one that can be typed into.
- Only the caret is restored, not the value: the field is a `search_form_for`
  field, so the server rendered what was typed back into it. `preventScroll`
  keeps a refocus from jumping a long page back up to the form.
- Ticking or unticking an option in a filter submits immediately, with no
  debounce: a filter is one decision, and the table should answer it. A combobox
  writes its hidden input from JavaScript and fires no native `change`, so the
  controller listens for Bootstrap's own `change.bs.combobox`, which bubbles —
  one listener on the form hears every menu inside it.
- What the answer replaces is the table and nothing else. `index.html.erb` wraps
  it in `<turbo-frame id='results' data-turbo-action='advance'>` and the form
  carries `data-turbo-frame='results'`, so a menu stays open while it is picked
  from and the caret stays in the search box, while `advance` still puts the
  query in the address bar for a reload or a shared link to answer.
- The frame wraps *both* branches of the empty check, the table and the
  `none` partial alike. A search that matches nothing has to answer with the
  frame it was asked for, or Turbo replaces the table with an error about the
  frame it could not find.
- What a search matched is marked in the cell that matched it, with `<mark>`,
  through `search_highlight`. A table of twenty rows that all matched says
  nothing about *why* each one did; the mark is the answer, and it is why a
  search and a filter read differently on the same page.
- Only what the search looked through is marked: the model's own searchable
  columns, and the label behind a foreign key the search reaches through, so
  `/locations` marks the ZIP code it matched. Marking a word in a column nobody
  searched would claim a match that never happened.
- `mark { padding: 0 }` in the layout. Bootstrap gives `<mark>` padding of its
  own, which pushes the matched letters apart from the rest of the word —
  `Nash` in `Nashville` reads as a word standing on its own rather than as the
  start of one.
- A marked table is never cached, which the caching rule below already ensures:
  a fragment keyed on the relation alone would serve one search's marks to
  another's rows.
- A link inside that frame navigates that frame, and only two kinds should: a
  heading, which sorts it, and a pagination link, which pages it. Both answer with
  a page that has the frame in it.
- Every other link in a table leaves it, and a page it leaves for has no frame of
  that name — Turbo replaces the table with `Content missing` rather than going
  there. So a link in a cell carries `data-turbo-frame='_top'`, and
  `turbo_link_to` is what puts it there: the edit pencil goes through it, and a
  host's own row partial should too rather than reaching for `link_to`.
- It is worth being able to check. On `/contacts` the frame holds one link, the
  pencil, and it is `_top`; on `/counties` it holds nine, three sorts and six
  pages, and none of them are.
- A heading clicked inside the frame changes the order without redrawing the
  form, so the form's hidden `q[s]` is stale from that moment. The controller
  reads it back off the address bar on `turbo:frame-load` — which is why the
  field is rendered even when nothing is sorted, and why that listener is on
  `document` rather than on the form, whose subtree the frame is not in.
- None of this is required for the page to work. Without Turbo the form is an
  ordinary GET that reloads everything, which is also when the caret has to be
  put back by hand.

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
- A phone *field* separates as it is typed, not only once it is stored. Every
  `<input type='phone'>` carries the Stimulus controller that does it:

      data-controller='phone'
      data-action='keydown->phone#down input->phone#input'

- The controller formats on `connect` too, so a form redrawn after a rejected
  `create` shows the separators rather than the ten digits it was sent.
- Because the value now carries separators, the `pattern` has to accept them or
  the browser refuses to submit what it just helped type. A phone's pattern is
  therefore `[2-9]\d{2}-[2-9]\d{2}-\d{4}` — the separated form of the model's
  `NORTH_AMERICAN_PHONES`, keeping the rule that an area or exchange code cannot
  start with 0 or 1. The server sees bare digits regardless, since `Phonable`
  normalizes them away.
- Never put a length validator on a phone. `maxlength` would come from it and cut
  the value off at ten characters, three short of `555-555-5555`.
- The `title` says `Please match the format 555-555-5555`, matching the
  placeholder. Where a field has a canonical sample the title uses it rather than
  a shape derived from the pattern, so the two never disagree.

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
