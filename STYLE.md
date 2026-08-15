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
- The gem ships `app/views/layouts/recourses.html.erb`, and every screen it serves
  renders in it: Bootstrap's CSS in the head, the JS bundle as a module before
  `</body>`, and no webfont: text is `helvetica, verdana, arial, sans-serif` at
  14px (`0.875rem`, so a browser's text-size setting still scales it), set
  through `--bs-body-font-family` and `--bs-body-font-size` in the layout's own
  `<style>`. Nothing on the page reaches an external host.
- Named for the controller rather than for the app. `RecoursesController` implies
  `layouts/recourses` and finds it in the gem before Rails falls through to
  `layouts/application`, so a host's own layout is not involved — and a host with no
  layout of its own is not left rendering *its* pages in this one, which is what
  shipping `layouts/application` did.
- A host puts its chrome back by writing `app/views/layouts/recourses.html.erb` of
  its own, which wins on being earlier in the view paths, or by declaring
  `layout 'application'` on a controller that subclasses `RecoursesController`.
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

## The primary colour

- Bootstrap's primary is blue, and `Recourse.color` is what changes it — nil by
  default, and one of `blue`, `gray`, `orange`, `purple`, `pink` or `brown`.
- Six of the sixteen families, because `--bs-primary-contrast` is white and these
  are the six dark enough at their 500 step to carry it. The other ten are
  declined rather than forgotten, and anything else raises.
- Never restyle a component to recolour it. `.theme-primary` maps all nine
  `--bs-primary-*` properties onto `--bs-theme-*`, so redefining those nine is what
  carries a colour to every button, link, sorted heading and focus ring at once.
- The nine live in `_color.html.erb`, copied from `bootstrap.min.css` in upstream's
  order and upstream's shapes with only the family swapped — including the
  two-branch `light-dark` focus ring, which is worth keeping verbatim so a later
  Bootstrap can be diffed against it.
- The block goes *after* the stylesheet link in the head. Both selectors are
  `:root`, so it wins on being later and nothing else; put it before and it does
  nothing at all.
- A host wanting the eleven, or a palette of its own, overrides that partial. It
  takes the family as its one local, so a host's version can ignore it entirely.

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
- Where they go is the layout's decision, and the gem's own layout is the one that
  makes it: the navbar, with the search pushed right. A host that replaces
  `layouts/recourses` and yields neither gets no buttons and no search box, the same
  way it gets no styling until it links the stylesheets — the gem's layout is what
  such a layout is modelled on.
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
- A crumb that is not a link keeps its resting colors on hover: Bootstrap lights
  every `.breadcrumb-link` under the cursor, which on a `<span>` promises a
  click that goes nowhere. The layout redefines the two
  `--bs-breadcrumb-link-hover-*` tokens on `span.breadcrumb-link` — the element
  is what tells a link from the rest, since a crumb that links is an `<a>` — and
  gives the `.active` span its own resting color back, rather than out-cascading
  Bootstrap's hover rule.
- Whatever shares that line sits vertically centred on it, and what separates a
  line from the next one is the container's `row-gap-2` rather than a margin on
  anything in it. A margin is there whether the item wrapped or not, so the
  `mt-2 md:mt-0` the search form used to carry dropped the field a few pixels
  below the breadcrumb at every width where the two still shared a line.
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

## Deleting a record

- The delete lives on the edit page and nowhere else, contributed with
  `content_for :actions` so it sits beside the breadcrumb. Not in the table: a
  row of pencils with a bin beside each is a mis-click waiting to happen, and the
  warning below is only worth writing if it cannot be bypassed.
- It is a `button_to` rather than a link, since a delete is not a GET, wearing
  `btn btn-sm btn-outline theme-danger ms-3` — the `Add <resource>` button's
  classes in the colour that means this one is different. Its form takes
  `d-inline-block`, or it would break the navbar's line.
- It appears only where the `destroy` action is implemented *and* routed, the two
  guards `Add <resource>` and the edit pencil already answer to.
- It asks first, through `data-turbo-confirm`, and the wording is settled in
  CLAUDE.md rather than here — the text names the record, counts a level of what
  goes with it, says what is kept instead, and ends `This cannot be undone.`
- The count stops at one level on purpose. Every `has_many` costs one `COUNT` on
  an indexed key; counting a state's whole subtree means joining 40,965 ZIPs to
  render an edit page, so `Anything under those goes too` stands in for the rest.
- The warning shows in a Bootstrap 6 Dialog — v6's rename of Modal, built on the
  native `<dialog>` element, whose `showModal()` brings the focus trap, Esc and
  the top layer for free — never in the browser's own `confirm()` box.
  `Turbo.config.forms.confirm` is the hook, assigned in the layout; the wording
  still travels in `data-turbo-confirm`, unchanged, and the dialog is only how it
  is displayed.
- The markup is `recourses/_confirm`, rendered once by the layout after the
  flash, empty: `/recourse/confirm.js` fills the title with the message's first
  line and the body with a `<p>` per remaining line — `textContent`, never
  `innerHTML`, because the title carries a record's name and a name is data.
- `dialog-slide-down` is the animation, shipped by v6 — no CSS of ours — and
  reduced-motion turns it off in the same stylesheet.
- The footer reads Cancel then Delete: Cancel is `btn btn-solid theme-secondary`
  with `data-bs-dismiss='dialog'` and `autofocus`, so Enter lands on the safe
  answer; Delete is `btn btn-solid theme-danger` with `recourse-confirm-delete`
  as its JavaScript hook, unstyled.
- Cancel, Esc and a click on the backdrop all answer no, through one
  `hidden.bs.dialog` listener; only the Delete button answers yes.
- Turbo is what asks. Under a host layout that does not load it the button still
  deletes, with nothing asked first — the same bargain as everything else the
  gem's own layout brings — and one that loads Turbo without this layout's hook
  gets the browser's `confirm()` back, which is the graceful floor.

## Icons on resource links

- A link to a resource is preceded by a Bootstrap Icon, using the `<i>` form:
  `<i class='bi bi-person-rolodex'></i> Contacts`. The layout loads
  `bootstrap-icons@1.13.1`.
- Which icon is the *model's* to say, through `recourse_icon`, and never a list
  kept here. That list existed in two places — a map in `lib/recourse/icons.rb`
  and a copy of it in this file — keyed by the title as it displayed, so a
  resource renamed anywhere lost its picture silently.
- A model names a *concept* rather than an icon: `:train`, not `train-front`.
  `Unicon` says what that concept is called in Bootstrap Icons, and in SF Symbols
  and Material Symbols for whatever draws these records next.
- The default is the model's own name, so nothing has to be declared to be right:
  a `Contact` draws `person-rolodex`, a `Job` a hammer, a `Booking` a
  calendar-check. All sixteen models in the dummy app land on the icon the old
  map had chosen for them by hand.
- `def recourse_icon = :bag` in the model overrides it, for when the concept a
  model is named after is not the concept it means.
- A name Unicon has never heard of draws a circle rather than raising, which is
  what the old `FALLBACK_ICON` did and one fewer thing for this gem to hold.
- The breadcrumb's current page carries its icon too, though it is not a link:
  `/locations` reads as the pin and then `Locations`. It needs `gap-2` for the
  same reason a link does — only `.nav-link` ships a gap of its own.
- A crumb naming a page rather than a resource gets none. `New market` is not a
  thing with an icon, and the crumb before it is already showing the market's.
- The record a nested page stands under is a crumb of its own — `Counties`, then
  `Autauga County`, then `ZIPs` — linking to the record's show page where one is
  routed, and plain text where none is. Icon-less either way: it names a record,
  and the crumb before it already carries the resource's.
- The tab wears it too. The layout draws
  `<link rel='icon' href='data:,' data-controller='favicon'>` and the controller
  replaces the `href` with a data URI it draws, so `/counties` is a map in the tab
  strip and `/markets` a shop. `data:,` is an empty document, which is what keeps
  the browser from asking a host for a `/favicon.ico` it has no reason to have.
- Drawn from the font rather than shipped as an image. The codepoint is in the
  stylesheet and nowhere JavaScript can ask for it, so the controller has an
  element wear `bi bi-map` and reads what its `::before` would have said. The
  probe is rendered and hidden rather than `display: none` — a box that is never
  generated has no pseudo-element to report on.
- Nothing is drawn until `document.fonts.load` resolves. `connect` runs long
  before the font arrives, and a character the font has not brought is a blank
  box, which is exactly what would end up in the tab.
- 64 pixels square, in the page's primary colour: an app that sets
  `Recourse.color = :pink` gets a pink tab as well as pink buttons. `--bs-primary-fg`
  rather than `-bg`, since that is the one a link is drawn in and the one that adapts
  to the colour scheme — `light-dark(600, 400)`, darker on a light page and lighter
  on a dark one, which is what a tab strip wants too.
- Resolved by painting rather than by reading. `getPropertyValue` on a custom
  property hands back `light-dark(var(--bs-pink-600), var(--bs-pink-400))`, which a
  canvas cannot parse, so the probe that already reads the codepoint wears
  `color: var(--bs-primary-fg)` and its computed `color` is read off the same call.
  A host without those properties falls back to the inherited colour, which is where
  this started. A tab asks for 16 and twice
  that on a retina display; a glyph scaled down reads better than one scaled up.

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
- Only while they are one line, though: the row is
  `align-content-start md:align-content-stretch`. Stacked, the sidebar and the
  content are two lines of a wrapping flex row, and `align-content: stretch`
  hands each of them half of whatever height the page has left over — a band of
  empty space under a dozen links, and the rule stranded well below them. Packed
  to the top instead, they sit against each other; from 768px the single line is
  stretched again, which is what draws the rule the whole way down.
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

## The card a record sits in

- A record's pages — `show` and `edit` — put their content in a `.card` whose
  `.card-header` holds a `ul.nav.nav-tabs.card-header-tabs`, one tab per page the
  record has. `card-header-tabs` is what pulls the row up into the header's padding,
  so the active tab meets the body it belongs to instead of floating above it.
- The body takes `align-items-stretch`. A `.card-body` is a column flex container
  that packs its children to the start, so a form of two fields would be as wide as
  two fields rather than as wide as the card, and its grid would stop halfway across
  the page. Stretched, every page fills the card whatever it holds: two columns of
  equal width, or one field taking half the row.
- Tabs are *links*, not a JavaScript tab set: each is a page of its own, with its own
  URL and its own breadcrumb. The current one carries `.active` and
  `aria-current='page'`, the same pair a sidebar entry uses.
- A look before a change, the order the seven actions are drawn and the order the row
  links follow. Each tab wears that link's icon — the eye and the pencil — from one
  `ICONS` map, so a row and a card cannot come to disagree about which is which.
- After them, one tab per has_many whose rows have an index nested under the
  record, wearing that model's icon. The nested route is the whole requirement; a
  counter cache only decides how the tab reads: `8 ZIPs` where the record keeps
  one — the number read off the record itself, like the column, so the tab costs
  no query — and the bare `ZIPs` where it does not. The count is what earns the
  downcase; a word that leads keeps its capital, like the Show and Edit beside it.
- A nested index is one of those pages, so it sits in the same card — the *parent*
  record's — with its own tab as the current one and the parent's own Show and
  Edit tabs beside it, each drawn only where its route is.
- One tab where a resource has only one of the two pages, rather than no card: the
  card is what says which page of a record is being read, and that is worth saying
  even when there is only one.
- `new` gets no card. There is no record yet, so there is no other page of it to
  offer, and a single `New` tab would name the page it is already on.

## The show page

- It is the edit page with the form taken out. Same `.row`, same
  `mb-3 lg:col-6` per attribute — two columns on a large viewport, one below it —
  and the same title, the record's own label, so a look and a change never
  disagree about what the page is called.
- One rule between rows, so a heading and its value read as one thing and the next
  pair as another. It sits on the cells rather than between them — a column's gutter
  is padding inside it, so two side by side draw one unbroken line — and it is
  `.recourse-values > .recourse-row` that colours it in.
- Every row on *both* pages reserves the width that rule takes, in `transparent`, and
  carries the same `pb-2 mb-3`. That is what leaves a field at exactly the height of
  the value it edits, row after row: the two pages line up to the pixel, so switching
  tabs moves nothing but the controls.
- Which needs two things of the show page's values, both of them about a value being
  as tall as the control that edits it. `.form-control-plaintext` takes a control's
  `min-height`, which Bootstrap defines for it and then never applies; and the reveal
  button loses `.btn-sm`'s, since it is a word beside a value rather than a control
  beside it.
- Each attribute is a heading and a value, not a definition list: a
  `<div class='form-label'>` above a `<div class='form-control-plaintext'>`. The
  first is the class the form's `<label>` wears and the second is Bootstrap's own
  read-only control, whose padding and line height are a control's, so a value sits
  exactly where the input holding it would have.
- `.form-control-plaintext` and not a disabled `.form-control`: a box a person
  cannot type in invites them to try. This page has no form on it at all, which is
  the whole difference from the edit page.
- One row per *editable* column, the same list the form offers, so the two pages
  never disagree about which attributes a record has. Encrypted columns included.
- Then `created_at` and `updated_at`, always, at the end and in that order. A
  record's own page is where "when" belongs — however firmly its index keeps the
  two off the table unless `recourse_timestamps` asks — and the form never offers
  them, since Rails keeps them. The shared rows still line up with the edit page;
  the show page is simply two rows longer.
- Each value reads as what it is *of*, not as what it is stored as. A foreign key is
  the label of what it points at, a date is `Aug 12, 2026`, an integer carries its
  delimiters, a decimal is rounded to its own scale, a price wears the currency and a
  percentage a `%`, and a phone is punctuated.
- A boolean is a picture: `Unicon[:check]` for true, `Unicon[:close]` for false, and
  `Unicon[:square]` for the one a record never answered. Three states rather than two
  and a dash, because an empty box is a fact about the record and a dash is a fact
  about the page. Each carries an `aria-label`, since an icon says nothing aloud.
- An enum is a `.badge`, in the word the column holds rather than a humanized one —
  the same word the form's menu offers, so the two never read differently.
- A counter cache is not on the page at all. Rails keeps it, so there is nothing to
  read and nothing to set; the index table is where a count belongs.
- An encrypted value arrives masked: one `*` per character, and a `Show` beside it
  that swaps the plaintext in. The plaintext travels in a
  `data-reveal-plain-value` attribute and the swap is a Stimulus controller, so
  what a screenshot catches is asterisks and reading one value is a click. See
  CLAUDE.md, "Encrypt PII", for why the page shows PII at all.
- The `Show` is a `<button class='btn btn-link btn-sm p-0 align-baseline'>`, not an
  `<a href='#'>`: it goes nowhere, and a link that goes nowhere is a link that
  breaks when middle-clicked. It removes itself once it has fired, since a reveal
  that has nothing left to reveal reads as though there were more to see.
- The mask and the button sit in the one `.form-control-plaintext`, made
  `d-flex gap-2`, so the pair stays on the line the value would have occupied.
- A value the record has nothing for reads as an em dash, so a heading is never left
  standing over a gap. `false` is something a record says, so only nil and an empty
  list get the dash.

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
- Which field a column gets is decided by what it holds, the same question the show
  page asks: `attribute_kind`. A checkbox for a boolean, a combobox for an enum, a
  number field stepped by what the column keeps, a telephone field for a phone.
- A checkbox goes *under* its label like every other control, not beside it the way
  Bootstrap's own examples put it. The grid is label-above-control throughout, and
  the show page draws the same attribute's icon under the same label.
- A number field says what it will take: `step="1"` for an integer, `step="any"` for
  a float, and for a decimal the scale as the step and the precision as the cap —
  `scale: 2, precision: 4` gives `step="0.01" max="99.99"`. No `min`: how far below
  zero a column may go is the model's business, not the schema's.
- A price and a percentage are attributes whose *type* says so — `Price` and
  `Percentage`, registered by the app, reporting `:price` and `:percentage` from
  `type_for_attribute`. The gem asks the attribute and never guesses from a name:
  `hourly_rate` is money and `commission_rate` is a share of it.
- A price and a percentage are adorned rather than labelled twice. The wrapper takes
  `.form-control form-adorn d-flex` and the border and padding with it, the unit is a
  `.form-adorn-text`, and the input inside is a `.form-ghost` with neither.
  `.form-adorn-end` reorders the pair, so `%` follows the number and the currency
  precedes it.
- The currency is `number.currency.format.unit` from the locale, never a `$` written
  into a view: an app that counts in euros says so once, where its numbers are
  already formatted.
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
- An encrypted attribute's field carries the record's own value in the clear, in
  the field its kind earns — a text box for a surname, an email input for an
  encrypted email. Editing one record is already a deliberate act, so the mask
  stays on the show page, where values are only read. A password field is for a
  column named `password`, and it renders empty on purpose: a stored password is
  written, never read back.
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
  `type:` for the input. `field :pin, type: :password` beats every rule below —
  an explicit type is an instruction, and it is how a secret not named
  `password` earns the box that hides it.
- The field type otherwise follows the column, and the rules are in this order: a
  foreign key is a combobox; a column named `password` is a password field; one
  named `email` gets an email input; a `date` or `datetime` attribute gets its
  own field, the second as `datetime-local`; a `text` attribute gets a textarea
  of a single row — the kind says the value may grow long, not that it starts
  big; everything else follows its kind, encrypted or not.
- A `color` input and a `time` one were here and are not: the dummy app's only
  columns of those kinds went with the market they belonged to, and a branch no
  page reaches is a branch nothing tests. Both are four lines to restore beside a
  column that wants them.
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

- A form asks for a foreign key one of two ways, and two things decide. Where the
  label has a *length validator* it is short enough to type, so the field asks for
  the value; where the other table is too long to list — `recourse_listable?`,
  100 rows — it asks for the value too, because the alternative is a menu of
  everything. Otherwise it is a combobox to pick from.
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
- That input is a node the server never renders, which Turbo's DOM surgery
  knows nothing about — a morphing refresh deletes it while the plugin instance
  keeps writing to the detached node, and a snapshot restore resurrects an old
  one beside the input a fresh instance makes, so a click would submit a filter
  that is stale, doubled or missing. The toggle therefore carries
  `data-controller='combobox'`, whose lifecycle keeps input and instance one
  thing: `connect` removes any restored stale inputs and adopts the instance,
  `disconnect` disposes it (which takes its input with it), and a `turbo:morph`
  disposes and remakes it whole — the constructor reads the `.selected` items
  the morph just made truthful, so one move resyncs the input, the toggle's
  text and the listeners.
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
- The container carries `data-turbo-temporary`: a toast born visible would
  otherwise replay from the page snapshot on every Back, announcing a save that
  happened a page ago.
- The variant is the flash key: `toast theme-success` for a notice, `toast
  theme-danger` for an alert, and a neutral `theme-primary` for a key a host
  invents. The theme goes on the `.toast` itself.
- The message goes in the *header*, and the body is kept but hidden:

      <div class='toast fade show theme-success' role='alert' aria-live='assertive' aria-atomic='true'
           data-controller='toast'
           data-action='mouseenter->toast#stopTimer mouseleave->toast#startTimer focusin->toast#stopTimer focusout->toast#startTimer'>
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
- It autohides after five seconds, but not through the Toast default: the `toast`
  Stimulus controller owns the timer (see below), and hovering or focusing the
  toast holds it open — Bootstrap's own pause-on-hover only guards the timer *it*
  armed, so the controller's actions redo it.
- The wording names the model, never the record: `Contact was created.` and
  `Contact could not be created.`, both from `model_name.human`. Interpolating the
  record instead prints `#<Contact:0x000000012b6febc8>`, because Active Record
  leaves `to_s` as Object's.
- The server ships every toast `fade show`, so *appearing* needs no JavaScript at
  all: the toast paints with the page instead of waiting for the bundle to load
  and run. Bootstrap's `show()` must never run on one — it re-adds `showing` and
  blinks the toast through transparent — and it is also the only place Bootstrap
  arms its autohide, which is why the `toast` controller keeps `autohide: false`
  and runs its own five-second timer. Only the *hiding* is Bootstrap's, so the
  timer and the dismiss X share one code path and one fade.
- The exit is slower than the entrance it no longer has: the layout stretches
  `--bs-transition-fade` to one second on `.toast`, so the toast fades away
  rather than vanishing. Reduced-motion still wins — the vendored CSS sets
  `transition: none` outright under the media query, which no custom-property
  override can defeat.
- `data-bs-dismiss='toast'` still needs the component loaded, so the X is dead
  without the bundle — a `modulepreload` in the head is what has it in flight at
  first paint instead of discovered at the end of the body.

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
- A table that has actions opens with one column per action, and `_table` adds
  them rather than `_row`. That is the whole point of putting them there: a host
  that writes its own row still gets the columns, prepended before whatever
  columns that row defines, so `/contacts` reads `(eye) | (pencil) | ZIPs count |
  Name | Phone | Created at`.
- One column for the show page and one for the edit page, each drawn only where
  its action is routed. The heading and every cell are the icon rather than the
  word — `<i class='bi bi-eye'></i>` and `<i class='bi bi-pencil-square'></i>` —
  `action_header` answering the icon on the header pass and the action's word on
  every other, so each `data-cell` labels itself `Show` or `Edit`. The heading's
  icon carries `role='img'` and an `aria-label`, and each cell's link an
  `aria-label`, since an icon alone says nothing to a screen reader.
- A look before a change, in the order the seven actions are drawn. Never the
  other way round: the pencil is the one that matters, and putting it under the
  cursor first is how a row gets edited by accident.
- Every icon heading — the two actions and each counter — carries a Bootstrap
  tooltip on top saying what the icon is: `Show`, `Edit`, or the counted model's
  plural, the same word its `aria-label` already speaks. The title travels in
  `data-bs-title` and the `tooltip` Stimulus controller is what makes it,
  since Bootstrap never wires one on its own — and its `disconnect` disposes it,
  so a table Turbo redraws never strands a tooltip over an element that left.
- A resource missing an action gets no column for it, rather than a heading over
  an empty column on every row; a resource with neither opens at its first
  attribute.
- Each is a square: `.recourse-actions` asks for a width of
  `calc(1em * var(--bs-body-line-height) + 2 * var(--bs-table-cell-padding-y))`,
  which is exactly what a single-line cell stands tall — line box plus the two
  vertical paddings, with `box-sizing: border-box` making the two measures the
  same kind. The icon sits centred in it, and a table laying out to 100% hands
  what these cells do not use to the columns carrying text.
- `.recourse-counter` shares that rule, so a counter column starts at the same
  square — but a table treats the width as a preference, never crushing content
  into it, so a figure like `38,405` widens its column to be read whole;
  `white-space: nowrap` is what keeps it one line while it does. The class comes
  from `counter_class(name)`, which `_row` passes on every column and which
  answers only for a counter.
- Neither rule applies while the table is stacked, where every cell is a block
  and a square one is a squashed one — the `@container` query matches
  `.sm:table-stacked`'s.
- Not while the table is stacked, where every cell is a block and 1% of the row is
  a squashed one. The rule sits in a `@container (width >= 576px)`, which is
  `.sm:table-stacked`'s own query read the other way round, against the
  `.table-responsive` the table already sits in.
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
- So is anything a model declares `attr_readonly`. A value written once and never
  again is a fact about the row's identity rather than about the row, and
  `attr_readonly :fips` takes the FIPS column off `/counties` entirely.
- It comes out of the search box with the column. A search that matched a column
  no page draws would answer with rows carrying nothing that explains why they are
  there, and the mark that usually explains it has nowhere to go. A host that
  wants one searched anyway names the predicate itself, in `search_field`.
- `created_at` and `updated_at` are shown only where a model names them in
  `recourse_timestamps`, and come last when it does, in that order however the
  schema declares them. Neither by default: a timestamp is a fact about the row's
  storage rather than about the thing it stores, and on reference data written by
  a migration it repeats one instant three thousand times.
- A model asks for the one that means something. A booking and a contact show
  `created_at`, since when the work came in and when someone first reached the app
  are part of what those rows say; a setting and an app show `updated_at`, since
  both are written once and edited after — they are what Rails maintains rather
  than what the record is about, and a reader scanning a table wants its subject
  first.
- Column headings come from `human_attribute_name`, so a host app can rename
  one by translating the attribute.
- Counter caches lead the attribute columns, right after the action columns: a
  count is a link into the record's children, so it sits with the other things a
  row offers to click before what the row says.
- A counter cache is headed with the icon of what it counts — the same icon the
  sidebar and the breadcrumb draw for that resource, so the three agree without
  anyone naming it three times. The icon carries `role='img'` and an `aria-label`
  of the counted model's plural — `ZIPs`, not `ZIPs count` — which is also what
  every `data-cell` under it says. The cells hold the figure alone — `38,405`,
  no icon, delimited like the filter-menu counts beside the table — since the
  heading already names what the figures count.
- Every other numeric cell reads the way the show page reads it, through the one
  `formatted_number` ladder Formats keeps: integers delimited, prices as
  currency, percentages and decimals at their column's own precision. Only text
  cells are search-highlighted — a search never looked through a number.
- A value that is one absolute web address and nothing else — `WEB_URL` says
  which — is a link to itself on the table and the show page alike: Bootstrap's
  `icon-link` in its `icon-link-hover` style, ending in Unicon's `arrow_right`,
  so the arrow takes a step under the cursor and the value reads as somewhere to
  go. Words around an address, or two addresses, stay text.
- The arrow rides clear of the baseline: bootstrap-icons drops every glyph
  `-.125em` to sit on a text line, so the layout lifts `.icon-link > .bi::before`
  to `.0625em` — clear of the line without floating, and on the `::before`,
  never on the `.bi` box, whose transform is the hover step's to write.
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
  `search_field` is nil. A model with filters but nothing to search gets no form
  at all: a row of menus with no box to type into is not a search, and the page
  reads cleaner without it. The index puts it in `content_for :search`
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
  `filter_fields` entry whose predicate names a `belongs_to` or an enum. A multiple
  menu item ends with its own check, shown only once picked:

      <button class='menu-item selected' type='button' data-bs-value='1' aria-selected='true'>
        Alabama<i class='bi bi-check menu-item-check'></i>
      </button>

  Where the model a filter lists counts the rows being filtered, each option ends
  with that count: a `<span class='recourse-count fg-2'>` at the right of the row, in
  muted text, so the name reads first and the number answers "how many of these?".
  It stays in the menu: the name goes in a `.menu-item-content > span`, which is the
  one thing the plugin copies into the closed box, so a box showing one chosen option
  reads `Beverly Hills` and not `Beverly Hills4`. That wrapper is `flex: 1`, which is
  also what puts the count at the right without a margin of its own. The tick keeps
  its width while hidden, so ticking an option moves nothing.
- A counted menu is ordered by that count, descending, and by name where two options
  hold the same number. A menu is read from the top and most requests want the option
  most rows are behind; the name is what keeps two equal ones from swapping places
  between requests. Without a count to read, the order is the name alone.
- An option counting none of the rows is `d-none` rather than absent: the markup is
  there and the `All …` line reveals it, which is one more thing that line does
  besides unticking. `.d-none` and not a class of ours, since Bootstrap's utilities
  come last in its stylesheet and win over `.menu-item`'s own display without needing
  `!important` — and the plugin's search sets `style.display` rather than a class, so
  the two never fight. An option already ticked keeps its place in the menu.
  An enum's filter is the same menu over the words the column admits rather than over
  records: headed by the attribute — `Status`, not `Booking status` — since the row it
  sits in names other tables and this one names the table already being read. Its
  reset line reads `All statuses`, the column's own name pluralized.
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
- A model whose searchable columns are all encrypted gets a search box that asks
  for a whole value: `/agents` searches `email_eq` and prompts `Filter by exact
  email`, where `/states` searches `code_or_fips_or_name_cont`. A `cont` would be
  matching a LIKE against ciphertext and finding nothing, every time.
- Only deterministic encryption qualifies. Without it a value encrypts differently
  on every write, so even `eq` would never match — and that is a model's decision,
  not something a page can work around.
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
- A form asks the same two questions of the same foreign key, and either one is
  enough to make it a typed field: the label is short enough to type, or the table
  is too long to list. A county name has no length to bound it and 3,144 rows
  behind it, and the second question is what keeps a form from drawing every one
  of them.
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

## Live index refreshes

- When the host runs turbo-rails, an index page subscribes to its model's
  refreshes: `refresh_subscription` renders a `turbo_stream_from` on the plural
  stream every committed change broadcasts on, so a record saved in one browser
  redraws the table in every other one that has the page open.
- The subscription tag sits *outside* the `results` frame, so a search
  keystroke's frame navigation never tears the cable connection down and reopens
  it.
- The helper also asks the head for two metas, `turbo-refresh-method: morph` and
  `turbo-refresh-scroll: preserve`. Neither is Turbo's default, and without them
  a refresh replaces the whole body and scrolls back to the top.
- A refresh re-fetches the *current* URL, so the search, sort and page params
  the frame's `advance` put in the address bar all survive it.
- The search form sits a morph out: a morph would write the fetched page's older
  query over what is mid-typing, so the search controller cancels
  `turbo:before-morph-element` for anything in the form's subtree, keeping the
  text, the caret and any open filter menu. Never with `data-turbo-permanent`,
  which spans page visits too — every index names this form alike, so a sidebar
  click would carry the last resource's form, filters, and `action` into the
  next page's navbar.
- When turbo-rails is present the layout serves its bundle at
  `/recourse/turbo.min.js` instead of loading plain Turbo from the CDN — the
  same Turbo, plus the `<turbo-cable-stream-source>` element and Action Cable
  client that turn the subscription tag into a connection, in the version the
  host's own gem signed the streams for. Without turbo-rails nothing changes:
  no tag, no metas, the CDN script as before.
- Which models take part is the model's own business — `recourse_broadcasts?`,
  documented in the README — and the helper renders nothing for one that opted
  out.

## Links

- Internal links go through Turbo, so navigation is a fetch and a swap rather
  than a full page load. The layout loads Turbo from the CDN, or from the host's
  own turbo-rails when it is there — see "Live index refreshes".
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

- Rails' `time_tag` builds both halves: `time_tag value, l(value, format:
  :recourse)`. Pass the text explicitly — left to itself the helper picks a format
  of its own.
- The `datetime` attribute is `rfc3339`, so it carries seconds and the offset.
  The visible text drops both; the attribute is what a machine reads.
- Zone comes from `config.time_zone`, so `%Z` reads `EDT` or `EST` depending on
  the date, never `UTC`.
- A date with no time of its own reads `Aug 12, 2026`, never `2026-08-12`. The
  ISO form is a value rather than something a reader takes in at a glance, and it
  already has a place on the page:

      <time datetime='2026-08-12'>Aug 12, 2026</time>

- The same `time_tag` draws it, so a date carries its machine-readable form the
  way a time does. `time_tag` writes `iso8601` for a Date and `xmlschema` for a
  time, which is why the attribute is the plain date here and the full offset
  above.
- Both formats live in the locale file, as `date.formats.recourse` and
  `time.formats.recourse`, and one `l(value, format: :recourse)` reads either:
  I18n picks the date format or the time one by what it was handed. So nothing in
  the code asks which it has, a `DateTime` — which is a Date *and* carries a time
  — keeps its time, and a host can show `12 Aug 2026` by writing one key.
- Namespaced under `recourse` rather than written to `default`, or the gem would
  be reformatting every date in the host app that mounted it.
- A locale with no `recourse` format raises rather than degrading: `l` looks its
  format up with `raise: true`, unlike `t`. A host translating these pages
  translates those two keys as well, or turns `i18n.fallbacks` on.

## Pagination

- Paginate with the `pagy` gem, never hand-rolled offsets.
- The page limit is 20, which is already pagy's own default — so never pass
  `limit:` to restate it.
- Below the table, in this order: `info_tag` for the item count, then
  `series_nav :bootstrap` for the links. Both need `<%==` rather than `<%=`,
  since they return HTML.
- Leave `max_limit` unset. Without it pagy ignores a `?limit=` in the query
  string, so a visitor cannot ask for a page of 100,000 rows.
