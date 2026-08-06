# Coding Guidelines

**Scope:** This file is the authority for code style in this project. The
baseline is standard community Ruby/Rails practice, plus the learned preferences
recorded at the bottom.

## Ruby

- Two-space indentation, no tabs. No trailing whitespace; newline at EOF.
- `snake_case` for methods/variables, `CamelCase` for classes/modules,
  `SCREAMING_SNAKE_CASE` for constants.
- Predicate methods end in `?`; mutating/dangerous variants end in `!`.
- `do...end` for multi-line blocks, `{...}` for single-line blocks.
- Guard clauses over nested conditionals. Return early.
- Use `unless` for simple negatives; never `unless ... else`.
- Prefer `&.`, `||=`, `Array()`, `Hash#fetch` with defaults, and keyword
  arguments over positional args once there are more than two.
- Keep methods short and single-purpose. Extract private methods freely.
- Comment *why*, not *what*. Don't narrate the code.

## Rails

- **Follow the Rails Way.** Reach for framework features before writing
  custom infrastructure.
- Fat model / skinny controller. Controllers do routing, authorization,
  params, and rendering — nothing else.
- RESTful routes and the seven standard actions. Prefer nested resources or
  new controllers over custom actions.
- Use strong parameters; never pass raw `params` to a model.
- Scopes for reusable queries; avoid query logic in controllers or views.
- Guard against N+1 with `includes` / `preload` / `eager_load`.
- Validations and DB constraints together — the database is the last line of
  defense (null constraints, unique indexes, foreign keys).
- Migrations are reversible; never edit a migration that has shipped.
- Concerns for genuinely shared behavior, not as a dumping ground.
- Background jobs (Active Job) for anything slow or external.
- Secrets in credentials/ENV — never committed.
- Views: partials and helpers over logic in ERB. No queries in views.
- I18n for user-facing strings.

## Testing

- Never test another library. `validates :name, presence: true` is Rails'
  behavior, already tested in Rails, so a test asserting a blank name is
  invalid tests nothing of ours. Same for a unique index raising, or pagy
  splitting 25 rows across two pages.
- Test our data, our wiring, our own methods: what a backfill contains, what a
  helper returns, what markup a view produces, how many queries a page costs.
- Every behavior change comes with a test.
- Test behavior and public interfaces, not private implementation details.
- Descriptive test names that state the expected outcome.
- Prefer fixtures/factories that are minimal and explicit.
- Keep tests independent and order-agnostic.

## Git

- Small, focused commits. Imperative mood subject lines ("Add", not "Added").
- Explain *why* in the body when the change isn't self-evident.

---

## Learned preferences

Guidance from Claudio, recorded as it comes up. These override the baseline
above when they conflict.

Grouped under what each rule is *for*: performance, security, testing,
maintainability, readability, internationalization. A new rule goes under the
heading it serves, not at the end of the file, and a rule that could sit under
two is filed under the one a reader would look in first.

### PERFORMANCE

#### PostgreSQL, always

- When an app needs a database, it is PostgreSQL. Never MySQL, never SQLite —
  `test/dummy` included, and even where SQLite would be less setup.
- So the suite needs a running PostgreSQL. `test/test_helper` creates the
  database on first run, so `rake test` is still the only command.

#### Cache a query or a fragment that repeats

- Reach for `Rails.cache` wherever the same rows would be read or the same
  markup re-rendered.
- Key a fragment on the *relation* — `cache recourses do` — never on a
  hand-rolled string. Rails digests the SQL and pairs it with a version from
  the row count and newest `updated_at`, so nothing has to expire it.
- That version check costs a `SELECT COUNT(*), MAX(updated_at)`, and it is the
  price of never serving a stale menu. `recourses.cache_key` skips the check
  and queries nothing, at the cost of never noticing a new row — only behind an
  `expires_in`, and only for data that may lag.
- A list with no relation behind it has no version to check, so key it on a
  digest of the list itself. A fixed string goes stale the moment the list
  changes, which is silent: `Digest::SHA256.hexdigest Unicon.icons.join(',')`.
- The check is free where the relation is already loaded, which is why an index
  costs nothing extra: `blank?` loads it before the table renders. One more
  reason to prefer `blank?` over `empty?`.
- Cache the table, not the pagination around it.
- A cache that is off in tests is a cache nobody tests. The dummy app sets
  `config.cache_store = :memory_store` for test.

#### Fewest SQL queries to render a page

- Treat an extra query as a defect, not a detail.
- Checking whether a relation has records *and then looping over them*: use
  `present?` / `blank?`, never `any?` / `empty?`. `blank?` runs the `SELECT`
  the loop needs anyway; `empty?` adds a `SELECT 1 ... LIMIT 1` first.
- `any?` and `empty?` are still right when nothing will be looped over.
- An index eager-loads every `belongs_to` its table can name —
  `resource_class.includes(*names)` — or each referenced cell is its own query.
  Twenty locations: five queries, not forty-two.
- Assert the query count in a test, so a later edit cannot add one back. See
  `test_it_costs_one_count_and_one_select`.

#### Select only the columns a query displays

- A query built to display something fetches those columns and no others:
  `State.select(:id, :name).order(:name)`, not `State.order(:name)`.
- The count of queries is one cost; the width of each is another.
- Only where the columns are known. A generic table hands the record to a row
  partial that may touch anything, so it selects everything on purpose.

#### Emails are citext

- A plaintext email column is `citext`, never `string` — that is what makes
  comparison and a unique index agree that `Ada@` and `ada@` are one address.
  Run `enable_extension 'citext'` before the first such column.
- Nothing else needed: no `LOWER(email)` index, no downcasing on the way in.
- An *encrypted* email column is not citext: it holds ciphertext, so a
  case-insensitive column compares the wrong bytes. Normalize in Rails, always
  with both options: `encrypts :email, deterministic: true, downcase: true`.
- `deterministic: true` is not conditional on the column being queried *today* —
  an address is the natural handle for finding a record, and switching later
  means re-encrypting every row. `downcase: true` is what keeps a unique index
  honest: without it two spellings encrypt to two values.

### SECURITY

#### Encrypt PII

- Personal data uses Active Record Encryption: `encrypts :phone`, `:email`,
  `:surname`, `:street`. Suspect a column is personal? Ask before storing it
  in the clear.
- `name` is not PII and is not encrypted. A first name alone identifies nobody;
  a surname does. Asked and settled.
- A column that is queried or must stay unique needs `deterministic: true`.
  Non-deterministic ciphertext differs every write, silently defeating both a
  unique index and a uniqueness validation — they pass while duplicates pile up.
- Never constrain the *shape* of an encrypted value in the database. Only
  `null: false` and a unique index still mean anything; format is the model's.
- Encrypting a column removes it from every generic table. Intended — see
  `STYLE.md`.

#### Phone numbers

- A `phone` column holds exactly 10 digits, with `null: false` and a unique
  index. The database cannot check the shape: a phone is PII, so it is
  encrypted.
- The shape is Rails', in a `Phonable` concern:

      NORTH_AMERICAN_PHONES = /\A[2-9]\d{2}[2-9]\d{6}\z/

      normalizes :phone, with: ->(phone) { phone.delete('^0-9').delete_prefix '1' }

      with_options format: { with: NORTH_AMERICAN_PHONES, message: '...' } do
        validates :phone, allow_nil: true
      end

- The concern is `allow_nil`, so whether a phone is *required* is the including
  model's call — `presence: true` there, not in the concern.

### TESTING

#### Coverage stays at 100%

- `simplecov` starts at the very top of `test/test_helper.rb`, before anything
  else is required, with `minimum_coverage 100`. Below that the suite fails.
- `skip '/test/'` leaves the dummy app out: it is a fixture, not shipped code.
  Never `add_filter` — deprecated in favor of `skip`, and it warns every run.
- `lib/recourse/version.rb` is not measured, and that is expected: the Gemfile's
  `gemspec` directive loads it before SimpleCov starts. Do not add
  `track_files` — it would report as uncovered when in fact it runs.

#### As few tests as coverage needs

- A test that can be deleted while coverage stays at 100% is a test to delete.
  Write the smallest set that gets there and stop.
- Never add a test for lines already covered, even to reach a *branch* that is
  missed. Line coverage is the whole budget.
- Never test a migration: a backfill's row count and values are data, and
  asserting them exercises no code of ours.
- A model that only declares validations, associations and encryption gets no
  test file — nothing measured runs.
- This narrows "every behavior change comes with a test": the test comes with it
  only if it reaches a line nothing else does.
- Two assertions are exempt, because a covered line cannot stand in for them:
  how many queries a page costs, and whether an encrypted column reaches the
  page. Both run identical lines whether they hold or not, so coverage stays
  green while the behavior breaks — a PII leak printed an address at 100%.
- Nothing else is exempt. Markup, titles, breadcrumbs, icons, pagination and
  sidebar order are asserted by whichever test renders the page.

### MAINTAINABILITY

#### No metaprogramming

- Never `send` or `public_send`. Reach the data directly:
  `resource.attributes[column]`.
- No `define_method`, `method_missing`, `instance_variable_get` / `_set`,
  `const_set`, `constantize`, or `eval`.
- The one exception is an explicit instruction. Never on your own initiative,
  and existing uses are not permission to add another — ask.

#### Both sides of an association

- A `belongs_to` gets the matching `has_many` by default. Reading a foreign key
  from one side only is half the model.
- `dependent:` follows what the child requires: `:destroy` where it needs the
  parent (a `Job` without its `Location`), `:nullify` where optional (a
  `Message` may have no `Job`).
- `:destroy`, not `:restrict_with_error`. An admin deleting a record is entitled
  to the tree under it, and a `State` reaches counties → ZIPs → locations →
  jobs. The cascade exists so nobody dismantles that by hand.
- Which is why a delete needs a modal naming what will go, and how much.
  **Ask Claudio about that wording before designing the destroy page.**
- `has_many` takes one name, unlike `validates`. `has_many :counties, :markets`
  reads `:markets` as a scope and fails later with `undefined method 'arity'`.
- Neither side helps against `delete_all`, which is raw SQL and skips callbacks.
  A test clearing a parent table still needs the children gone first.

#### An enum is a Postgres type

- Native type, not an integer and not a bare string:
  `create_enum :job_status, Job::STATUSES`, then
  `t.enum :status, enum_type: :job_status, default: :draft, null: false`.
- Names live in a `STATUSES` constant on the model, one per line with a comment
  saying what that state means; the model declares
  `enum :status, STATUSES.index_by(&:itself)`. The migration reads the same
  constant, so type and model cannot drift.
- An array column is `t.text :media_urls, array: true, default: [], null: false`
  — always an array, so nothing has to check for nil first.

#### Trailing comma on a multiline hash or array

- The last entry ends with a comma, so adding one touches one line:

      NAVIGATION_ICONS = {
        'States' => 'geo', 'ZIPs' => 'geo-alt-fill',
      }.freeze

- The closing brace or bracket goes on its own line — `, }` reads worse than
  either alternative. This is also what decides how to break a literal that
  spans lines only because it is long:

      safe_join [
        @recourse_form.label(column, label, class: 'form-label'),
        resource_field(@recourse_form, column, type: options[:type]),
      ]

- Enforced by `Style/TrailingCommaInHashLiteral` and
  `...InArrayLiteral`, both `EnforcedStyleForMultiline: consistent_comma`. Not
  `comma`, which forbids it unless every entry is on its own line.

#### Keep render lines out of the logs

- Set `config.action_view.logger = nil` in `config/application.rb`. Action
  View's `Rendered ...` line per partial buries the request that matters.
- Everything else stays: request, SQL, and `Completed 200 OK` with view time.
- A rule for apps we write. The gem never touches a host's logging.

#### Keep RuboCop current

- `AllCops: NewCops: enable`. Fix what a new release surfaces; never pin.
- Enabling every new cop is not accepting every new cop. Decline one outright in
  `.rubocop.yml` with the reason beside it. `Gemspec/RequireMFA` is declined:
  MFA is settled on the RubyGems account, not asserted in gem metadata.
- `AllCops: SuggestExtensions: false`. We decline `rubocop-minitest` and
  `rubocop-rake` rather than postpone them.

#### Gemfile ordering and version constraints

- Alphabetical, one block, no blank lines — those read as separate groups.
- Never `~>`. Use `>=` only where a minimum is genuinely required, otherwise no
  constraint at all.
- Every gem carries a trailing comment saying why it is there — what would break
  without it, not what the gem is. Same for `add_dependency` in the gemspec.

#### No code of conduct, no ideology

- Never add a `CODE_OF_CONDUCT.md`, and never link to one. Delete it from
  generator output.
- Keep the codebase free of ethics, religion and politics — comments, docs,
  error messages, fixtures and sample data alike.
- `LICENSE.txt` is exempt: a license is a legal notice.

#### Target Rails 8.1+

- All Rails libraries at `>= 8.1`. Write against current APIs only.
- Never add version checks, shims or fallbacks for older Rails or Ruby.

#### No static typing

- Never write type signatures, never add a typing tool.
- No RBS: no `sig/`, no `.rbs`. `bundle gem` creates one — delete it.
- No Sorbet: no `# typed:` sigils, `sig { }` blocks, `T.let` / `T.nilable` /
  `T.must`, `srb` or `tapioca`.
- Never add: `sorbet`, `sorbet-runtime`, `rbs`, `steep`, `tapioca`.
- Convey intent through clear names, short methods and tests.

#### Branch and commit per prompt

- If the current branch is `main`, branch before starting. Short name, lowercase
  words, underscores only — `git_conventions`, `dummy_app`. Already on a branch:
  stay on it.
- Commit when the prompt's change is done. Subject summarizes the prompt; body
  is the full response given for it. One prompt, one commit.
- **No trailers naming who wrote it.** No `Co-Authored-By`, no session link, no
  tool credit — git already records an author.

#### Ask the validators, not the schema

- What a value may be is the model's business. A length validator gives a field
  its `maxlength`, a format validator its `pattern`, a numericality validator
  its numeric keyboard. Never read `columns_hash` for a `limit` or a type.
- Schema and validators disagree more often than it looks: a `limit: 5` column
  with no length validator accepts four characters, and an encrypted column's
  limit describes ciphertext.
- Where no validator can answer — `date` vs `time` vs `datetime` — ask
  `type_for_attribute`, so an `attribute :opens_on, :date` override counts.
- Corollary: a database constraint the model does not also state is one the
  browser cannot show. Add the validator too.

#### Match Bootstrap with field_error_proc

- Wherever Bootstrap is the framework, set
  `config.action_view.field_error_proc`. Rails' default `field_with_errors`
  wrapper gets no Bootstrap styling at all: no red border, no message.
- The proc adds `is-invalid` to the control and follows it with a
  `<small class='invalid-feedback'>` — Bootstrap reveals one only beside the
  other.
- Guard on the control's class, not the tag's type. A label carries
  `form-label` and falls through; guarding on `Tags::Label` instead leaves
  `html_tag.index 'form-control'` nil for every other tag, and `insert nil`
  raises.
- The proc is `instance_exec`'d on the view, so `tag` and `safe_join` are in
  scope. Use them: `insert` on a SafeBuffer escapes what it is given, so a
  hand-spliced attribute arrives as `&#39;`.
- A rule for apps we write — so a control the gem draws outside a form builder,
  like the combobox, carries this markup itself.

#### Every model says how it is labeled

- A model answers `recourse_label` with the column a combobox shows.
  `Recourse::Recoursive` supplies `:name` to every Active Record model through
  `ActiveSupport.on_load`, so most models say nothing.
- A model whose identity is not a `name` overrides it — `:code` for a ZIP,
  `:email` for an Agent — never in the model body, but in its own `Recoursive`
  concern at `app/models/zip/recoursive.rb`, inside `class_methods do`. The
  default arrives by `extend`, so only a class method can replace it.
- The label is what gets selected: `select(:id, label).order(label)`. So it must
  be a real column — a method would not survive the `SELECT`.
- Read it back with `recourse.attributes[label]`, never `public_send`.
- Picking an encrypted column labels the option with its plaintext, since
  `attributes` decrypts — a decision to make deliberately. It reaches past the
  form: a foreign key in a *table* shows the same label, so an encrypted one
  appears on the index of every model referencing it.
- `recourse_typed_label?` asks whether the label has a length validator, which
  decides between typing a value and picking from a list — a length says the
  value is bounded, so a person can type it.
- A typed label is looked up on the way in (`ZIP.find_by code: '90210'`) under
  the foreign key's own name, so no host model needs a virtual attribute.

#### What a gem always ships

- `bin/console` and `bin/setup`, whatever else it has: one to try the library in
  a REPL, one to get a clone working in a single command.
- A `CHANGELOG.md`, written before the release is made. Every entry says which
  of three it is — **fix**, **feature**, **breaking change** — because that is
  what tells a reader whether they can take it.
- The version follows from the entry, not the other way round. SemVer: fix →
  patch, feature → minor, breaking → major. Numbering first is how a minor
  release quietly breaks somebody.
- Keep an `## [Unreleased]` heading to collect entries, so a release is a rename
  rather than an act of remembering.

#### Git ignores a built gem

- `*.gem` is gitignored. `rake build` writes to the already-ignored `/pkg/`, but
  `gem build` leaves one in the working directory for `git add -A` to sweep up.
- Nothing is lost: `spec.files` reads `git ls-files`, so a build is never
  packaged inside the next one anyway.

#### Vendor what a page cannot render without

- A stylesheet or script a page cannot do without is vendored and served from
  the gem, never linked to a CDN — an unreachable CDN means an unstyled page.
- Files live in `vendor/recourse/`, served by an engine initializer through
  `Rack::Static`: the framework's own middleware, assuming no asset pipeline.
- Keep the slash on the prefix. `urls: %w[/recourse/]` matches on `start_with?`,
  so `%w[/recourse]` would 404 `/recourses` before the router ever saw it.
- Vendor whatever the vendored file asks for: `bootstrap-icons.min.css` loads
  `fonts/bootstrap-icons.woff2` relative to itself, and without it every icon is
  a blank box.
- Keep copies byte-identical to the CDN's, so a later version can be diffed.
- Our own JavaScript is not vendored. It lives in `app/javascript/recourse/` and
  is served at the same prefix — the first `Rack::Static` takes `cascade: true`,
  so a path it lacks falls through rather than 404ing. That keeps `vendor/`
  meaning "upstream's", which is what exempts it from the lint.
- A Stimulus controller imports Stimulus by its served path, not the bare
  `@hotwired/stimulus` specifier: resolving that needs an import map, and a host
  may ship its own.
- Start the application in the `<head>`, guarded by `window.Stimulus`. Turbo
  re-runs body scripts every visit, and a second application connects every
  controller twice.

#### Seed data lives in migrations, so schema.rb cannot load a database

- `config.active_record.dump_schema_after_migration = false`. Gitignoring
  `schema.rb` is not enough: it regenerates on every migrate, and Rails then
  loads it into the next empty database, stamping every version at or below its
  own as migrated — skipping the backfills and leaving the tables empty.
- Build a database with `db:migrate` from zero. Never `db:schema:load`, and be
  wary of `db:prepare`.
- `db:drop` will not drop a database with open connections and reports success
  anyway. `dropdb --force` is the reliable reset.

#### Design lives in STYLE.md

- Every decision about how a page looks is in `STYLE.md`. Read it before writing
  or editing any layout, view or partial.
- Where the two overlap, `STYLE.md` wins on markup and `CLAUDE.md` on Ruby.

### READABILITY

#### Say it short

- Between two versions that carry the same meaning, the shorter one wins. This
  covers everything written: comments, conventions, commit messages, docs,
  placeholders, and the words on a page.
- Same for names. Where two real English words fit — not acronyms, not
  inventions — take the shorter: `home` over `residence`, `job` over
  `assignment`. Model names especially, since every table, route, path helper
  and partial inherits the choice.
- Cut what the reader already has: the restatement, the second example that
  teaches nothing new, the sentence explaining why the rule is a good idea.
- Keep what makes a rule usable: the code, the numbers, the cop name and
  setting, and the gotcha that would otherwise be discovered the hard way.
- Brevity is not omission. If a rule cannot be shortened without losing how to
  apply it, leave it long.

#### Files at most 100 lines

- No code file over 100 lines, blank and comment lines counted. Split it —
  extract a class, a concern, a partial, a second test case.
- Enforced by `rake file_length`, part of the default task. RuboCop has no
  file-length cop: `Metrics/ClassLength` measures a class body, skipping
  comments and blanks.
- Exempt: `.md`, `.txt`, `.html`, `.erb` — prose is not code, and a view's
  length is driven by the page. `db/migrate/` — a backfill is as long as its
  data. `vendor/` — upstream's formatting is not ours, and a `.woff2` is not
  even text.
- **A rule for Ruby.** `ios/` is exempt entirely; Swift follows Swift's
  conventions, and a `UIViewController` split at a hundred lines reads worse.
- The task reads `git ls-files`, so an untracked file is invisible to it. A
  green run before `git add` proves nothing.

#### Lines at most 100 characters

- `Layout/LineLength` with `Max: 100`, down from its default of 120.
- Split long strings with `\` continuations rather than running over.
- Views are exempt (`.html`, `.erb`): a CDN URL or long class list cannot be
  wrapped usefully, and RuboCop does not lint them. So is Swift.
- When a call would need three lines and hanging indentation just to fit, hoist
  the long arguments into `with_options` — still three lines, but every one
  starts at a normal indent:

      with_options format: { with: SOME_PATTERN, message: 'is invalid' } do
        validates :phone, allow_nil: true
      end

#### Shared behavior becomes a concern

- Two models declaring the same behavior word for word: extract a concern.
  `encrypts :email, deterministic: true, downcase: true` stood in `Contact` and
  `Agent`, so it became `Emailable`.
- Name it after the feature, not the models: `Emailable`, `Phonable`.
- Only what they genuinely share moves. `Contact`'s email is optional and
  `Agent`'s required, so `presence: true` stays in each model.
- A second identical declaration is the threshold. Anticipating one is not.

#### Indent `when` inside a `case`

- `when` and `else` sit one level in from `case` and `end`:

      case params[:list]
        when 'unread' then Contact.with_unread
        when 'claimed' then Contact.claimed_by Current.agent
        else Contact.all
      end

- Enforced by `Layout/CaseIndentation` with `EnforcedStyle: end` **and**
  `IndentOneStep: true`. Neither alone is enough.
- `Layout/ElseAlignment` then follows `when`, so `else` needs no setting.

#### As few parentheses as possible

- Omit them on a call's arguments; keep the inner ones, where parsing needs
  them: `Object.const_set class_name, Class.new(RecoursesController)`.
- `Style/MethodCallWithArgsParentheses`, `EnforcedStyle: omit_parentheses`. The
  cop is off by default, so it needs `Enabled: true` too.

#### List concerns alphabetically, on one line

- `include Emailable, Phonable`, never the other way round. One `include`
  carries the list; split only when the line will not fit, keeping the order.
- Enforced by `Style/MixinGrouping`, `EnforcedStyle: grouped`. Its default is
  `separated`, which demands the opposite.
- `include A, B` inserts in reverse, so `A` lands ahead of `B` in `ancestors`.
  It matters only if both define the same method, which two concerns extracted
  for being distinct features should not.

#### Pass locals to partials explicitly

- A partial never reads a controller's instance variables. Declare strict locals
  on line one — `<%# locals: (resources:, pagy:) %>` — and pass them:
  `render 'table', resources: @resources, pagy: @pagy`. Rails then raises on an
  omission instead of rendering a blank.
- A partial taking no locals gets no comment. Never `<%# locals: () %>`.
- A template rendered by an action may read instance variables. The rule is
  about partials, which should not depend on who rendered them.
- Where two branches need different locals, write `if`/`else` rather than
  `render cond ? 'a' : 'b'` — one call cannot pass the right locals to both.
- The row partial is the deliberate exception, twice over: its record arrives
  under a runtime name (`contact:`, `state:`) so the gem's `_row` reads
  `local_assigns[resource_key]`, and header-vs-body travels in
  `@recourse_headers`, set by `_table`. Both were asked for; neither is a
  pattern to copy.
- The fields partial is the second exception, for the same two reasons — the
  runtime name, so a host's `_fields` can declare `<%# locals: (contact:) -%>`,
  and `@recourse_form`, set by `_form`, because `field :phone` is the call site
  the host writes.

#### Spell acronyms as acronyms

- Capitals wherever it appears: ZIP code, not Zip code; PIN, not Pin. Prose,
  comments, class names and labels alike.
- Register it so Rails agrees: `inflect.acronym 'ZIP'` in
  `config/initializers/inflections.rb`. Without it `human_attribute_name`
  renders `Zip` and every heading is wrong.
- It also fixes `camelize`, so `zip_code` becomes `ZIPCode` — worth knowing
  before naming a class after one.

#### Name non-trivial regular expressions

- A pattern that is not obvious at a glance gets a named constant, so the name
  explains the intent: `/\A[2-9]\d{2}[2-9]\d{6}\z/` is `NORTH_AMERICAN_PHONES`.
- Put it on the class that owns the rule and comment what it accepts and
  rejects — the name says what, the comment says why those bounds.
- Trivial patterns used once, like `%r{\Aexe/}`, stay inline.

#### Comment every public declaration

- Precede every public class, module, constant and method with a comment line
  saying what it is for. This narrows "comment why, not what": declarations get
  a *what*, and *why* still governs comments inside bodies.
- Say what it is for, not what the code shows. `# Raised for every failure the
  gem reports` earns its place; `# The Error class` does not.
- Never comment a private method — it earns its explanation from its name and
  its caller.
- Never put a method in a controller that only a view calls, and never
  `helper_method` to expose one. A view's needs belong in a helper or the
  template; a controller's private methods are for the controller.
- Indent `private` to match its `class`, not the `def`s under it, so it reads as
  a divider. `Layout/AccessModifierIndentation: EnforcedStyle: outdent`.
- A module reopened purely as a namespace is not redeclared — document it where
  it is defined.
- Enforced by `Style/Documentation` and `Style/DocumentationMethod` (off by
  default). Both skip `test/`, so test cases stay uncommented — their names
  state the expectation. Constants have no cop; comment them by hand.
- One line whenever possible. If one line cannot carry it, cut the aside rather
  than the rule — the detail belongs in the commit message.

#### Never freeze strings

- Never write `# frozen_string_literal: true`, including in generator output.
- Never `.freeze` a string, constant or not. Array and hash constants are still
  worth freezing by hand.
- Where a constant only names something, prefer a symbol — immutable already.
- `Style/FrozenStringLiteralComment` is `never`, and `Style/MutableConstant` is
  disabled: it demands `.freeze` on string constants and cannot skip them.

#### Single quotes by default

- Single-quoted strings. Double only where the string needs them: interpolation
  (`"#{name}"`) or escapes (`"\n"`).
- `Style/StringLiterals` and `Style/StringLiteralsInInterpolation`, both
  `single_quotes`.
- Views too, and HTML attributes and CSS values as much as Ruby:
  `<th scope='col'>`. RuboCop does not lint views, so this half is on us.
- Which is why assertions on that markup read
  `"<table class='table table-hover'>"`.

### INTERNATIONALIZATION

#### Eastern time

- `config.time_zone = 'Eastern Time (US & Canada)'`. That is what `Time.zone`
  means, what a form reads, and what a timestamp renders as.
- Storage stays UTC. Never touch `config.active_record.default_timezone` — the
  app zone is a display concern only.
- A rule for apps we write. The gem never sets a host's time zone.

#### American English, everywhere

- `color`, `gray`, `behavior`, `center`, `license`, `normalize`, `organize`,
  `recognize` — never the British spelling of any of them.
- Everything written, not just code: identifiers, comments, commit messages,
  docs, CSS values, and the words on a page. A heading spelled one way beside a
  button spelled the other is the tell that nobody chose either.
- Proper nouns are exempt — Centre County keeps its `re`, and so does every
  place name in `db/counties.txt`.
- Nothing enforces it. Watch the `-our`, `-re` and `-ise` endings, and `grey`.

#### I18n is deferred

- User-facing strings stay plain English until there are enough to be worth a
  locale file. Do not add one unprompted.

#### The State model

- A `State` is always a US state, with exactly three attributes, each non-null
  and unique: `code` (`'CA'`), `fips` (`'06'`), `name` (`'California'`).
- It always ships with a migration that creates the table *and* backfills it, so
  an app never starts with an empty one. Source:
  https://www2.census.gov/geo/docs/reference/state.txt
- 51 rows: 50 states plus DC. Territories are not states, so no `PR`, `GU`,
  `VI`, `AS`, `MP`, `UM`.
- `fips` is a string, never an integer — `'06'` must keep its leading zero.
- The database enforces all of it: unique indexes, `null: false`, `limit: 2`,
  and check constraints for the two-letter and two-digit shapes.

#### The County model

- A `County` has a unique non-null 5-digit `fips`, a non-null `name`, and
  belongs to a `state`. `name` is deliberately not unique — over twenty states
  have a Washington County.
- Always with a backfill of all 3,143 counties of the 50 states plus DC, each
  joined to its `states` row. Source:
  https://www2.census.gov/geo/docs/reference/codes2020/national_county2020.txt
- The first two digits of a county's `fips` are its state's. Check that after
  backfilling, not just the row count — by hand, since migrations get no test.
- The 3,143 rows live in `db/counties.txt`, not inside the migration. A
  decision, not a workaround: leave the data in the file.
- The database enforces it: unique index on `fips`, `null: false`, a five-digit
  check constraint, and a foreign key to `states`.

#### The ZIP model

- A `ZIP` has a unique non-null 5-digit `code`, a non-null `city`, a non-null
  `time_zone`, belongs to a `county`, and optionally to a `market`.
- The class is `ZIP`, not `Zip`. Register the plural too —
  `inflect.acronym 'ZIPs'` — or every heading reads `Zips`.
- That renames more than headings: Rails camelizes a migration filename to find
  its class, so `create_zips.rb` must define `CreateZIPs`. It breaks only on a
  migrate from zero, which is why a reset is the real test.
- Always with a backfill: every ZIP, matched to the county it mostly belongs to
  and the main city in it.
- `time_zone` holds a Rails zone name, never an IANA identifier. The source
  mixes both, so the backfill normalizes by offset and DST rules: Detroit and
  the Kentucky zones to Eastern, Indiana's Eastern zones to `Indiana (East)`,
  Knox and Tell_City to Central, Boise to Mountain, Anchorage and Nome to
  Alaska, Honolulu to Hawaii. Nothing should survive that
  `ActiveSupport::TimeZone::MAPPING` does not name — check by hand.
