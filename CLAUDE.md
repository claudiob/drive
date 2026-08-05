# Coding Guidelines

**Scope:** This file is the authority for code style in this project. The baseline is 
standard community Ruby/Rails practice, plus the learned preferences recorded at the bottom.

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

<!-- Newest entries at the bottom. -->

### No static typing

- Never write Ruby type signatures, and never add a strong-typing tool.
- No RBS: no `sig/` directory, no `.rbs` files. `bundle gem` creates one —
  delete it.
- No Sorbet: no `# typed:` sigils, no `sig { ... }` blocks, no `T.let` /
  `T.nilable` / `T.must`, no `srb` or `tapioca`.
- Never add these gems: `sorbet`, `sorbet-runtime`, `rbs`, `steep`, `tapioca`.
- Convey intent through clear names, short methods, and tests instead.

### Target Rails 8.1+

- All Rails libraries are required at `>= 8.1`. Write against current Rails
  APIs only.
- Never add version checks, shims, or fallbacks for older Rails or Ruby.

### Branch and commit per prompt

- Before starting a code change, if the current branch is `main`, create a
  branch first. Short name, lowercase words, underscores only — no dashes,
  no slashes, no ticket prefixes (`git_conventions`, `dummy_app`).
- If already on a branch other than `main`, keep working on it.
- After completing the code change a prompt asked for, commit it. The subject
  is a short summary of the prompt; the body is the full response given for
  that prompt.
- One prompt, one commit.

### Single quotes by default

- Always use single-quoted strings.
- Double quotes only when the string genuinely needs them: interpolation
  (`"#{name}"`) or escape sequences (`"\n"`, `"\x0"`).
- Enforced by RuboCop: `Style/StringLiterals` and
  `Style/StringLiteralsInInterpolation` are both set to `single_quotes`.
- This covers views too, `.html` and `.html.erb` included, and applies to HTML
  attributes and CSS values as much as to Ruby: `<th scope='col'>`, not
  `<th scope="col">`. RuboCop does not lint views, so this half is on us.
- A Ruby string containing single quotes then *needs* double quotes, which is
  why assertions on this markup read `"<table class='table table-hover'>"`.

### No code of conduct, no ideology

- Never add a `CODE_OF_CONDUCT.md`, and never link to or mention one from the
  README, gemspec, or any other file. Generators that create one (`bundle
  gem`) have their output deleted.
- Keep the codebase free of content about ethics, religion, or politics —
  including comments, docs, error messages, test fixtures, and sample data.
- `LICENSE.txt` is not covered by this: a license is a legal notice.

### Gemfile ordering and version constraints

- List gems alphabetically, in one block — no blank lines splitting the list,
  since those read as separate groups.
- Never use `~>`. Use `>=` only where a minimum version is genuinely required,
  and otherwise give no constraint at all.
- Every gem carries a trailing comment on the same line saying why it is
  there — what would break without it, not what the gem is.
- The same applies to `add_dependency` in the gemspec.

### Comment every public declaration

- Never comment a private method. The rule below is for the public surface; a
  private method earns its explanation from its name and its caller.
- Never put a method in a controller that only a view calls, and never reach for
  `helper_method` to expose one. If a view needs it, it belongs in a helper
  module or inline in the template. A controller's private methods are for the
  controller's own work.
- Indent `private` to match its `class` or `module`, not the `def`s under it, so
  it stands out as a divider. Enforced by
  `Layout/AccessModifierIndentation: EnforcedStyle: outdent`.
- Precede every public class, module, constant and method declaration with a
  comment line saying what that object does. This narrows the baseline's
  "comment why, not what" rule: declarations get a *what*, and the *why* rule
  still governs comments inside method bodies.
- Say what it is for, not what the code plainly shows. `# Raised for every
  failure the gem reports` earns its place; `# The Error class` does not.
- A module reopened purely as a namespace in another file is not redeclared —
  document it where it is defined.
- Enforced by RuboCop: `Style/Documentation` for classes and modules,
  `Style/DocumentationMethod` (off by default) for methods. Both skip `test/`,
  matching RuboCop's own default, so test cases stay uncommented — their names
  state the expectation.
- Constants have no cop; keep them commented by hand.
- Keep these comments to a single line whenever possible. If one line cannot
  carry it, cut the aside rather than the rule — the detail belongs in the
  commit message. Multi-line is a last resort, not a default.

### Name non-trivial regular expressions

- A regular expression that is not obvious at a glance gets a named constant,
  so the name explains the intent and the pattern is stated once.
  `/\A[2-9]\d{2}[2-9]\d{6}\z/` becomes `NORTH_AMERICAN_PHONES`.
- Put the constant on the class or module that owns the rule, and comment it
  with what it accepts and rejects — the name says what, the comment says why
  those bounds.
- Trivial patterns used once, like `%r{\Aexe/}`, stay inline.

### Spell acronyms as acronyms

- An acronym is written in capitals wherever it appears: ZIP code, not Zip code;
  PIN, not Pin. That covers prose, comments, class names and labels alike.
- When a model or column names one, register it so Rails agrees:
  `inflect.acronym 'ZIP'` in `config/initializers/inflections.rb`. Without it
  `human_attribute_name` renders `Zip` and every heading and label is wrong.
- Registering it also fixes `camelize`, so `zip_code` becomes `ZIPCode` rather
  than `ZipCode` — worth knowing before naming a class after one.

### Encrypt PII

- Personal data is stored with Active Record Encryption: `encrypts :phone`,
  `:email`, `:surname`, `:street`. Suspect a column is personal? Ask before
  storing it in the clear.
- `name` is not PII and is not encrypted. A first name on its own does not
  identify anyone; a surname does. Asked and settled — do not encrypt it.
- A column that is queried or must stay unique needs
  `encrypts :phone, deterministic: true`. Non-deterministic ciphertext differs
  every write, which silently defeats both a unique index and a uniqueness
  validation — they will pass while duplicates pile up.
- Never constrain the *shape* of an encrypted value in the database. What is
  stored is ciphertext, so only `null: false` and a unique index still mean
  anything; the format belongs to the model.
- Encrypted columns never appear in a generic table, so encrypting a column
  removes it from the index page. That is intended — see `STYLE.md`.

### The State model

- A `State` model always represents the United States, and always has exactly
  these three attributes, each non-null and unique: `code` (two capital
  letters, `'CA'`), `fips` (two digits, `'06'`), `name` (`'California'`).
- It always ships with a migration that creates the table *and* backfills it
  from the official list, so an app never starts with an empty states table.
  Source of truth: https://www2.census.gov/geo/docs/reference/state.txt
- 51 rows: the 50 states plus the District of Columbia. Territories are not
  states, so `PR`, `GU`, `VI`, `AS`, `MP` and `UM` are left out.
- `fips` is a string, never an integer — `'06'` must keep its leading zero.
- Enforce all of it in the database too: unique indexes, `null: false`,
  `limit: 2`, and check constraints for the two-letter and two-digit shapes.

### The County model

- A `County` has a unique non-null 5-digit `fips` string, a non-null `name`, and
  belongs to a `state`. `name` is deliberately *not* unique — more than twenty
  states have a Washington County.
- Creating a counties table always comes with a migration that backfills all
  3,143 counties of the 50 states plus DC, each joined to the right `states` row.
  Source: https://www2.census.gov/geo/docs/reference/codes2020/national_county2020.txt
- The first two digits of a county's `fips` are its state's `fips`. That is the
  invariant to assert after backfilling, not just the row count.
- Territories are left out, matching the states table.
- The 3,143 rows live in `db/counties.txt`, not inside the migration. Migrations
  are exempt from the file-length rule, so this is a decision rather than a
  workaround: leave the data in the file and do not inline it.
- The database enforces it too: unique index on `fips`, `null: false`, a
  five-digit check constraint, and a real foreign key to `states`.

### The ZIP model

- A `ZIP` has a unique non-null 5-digit `code`, a non-null `city`, a non-null
  `time_zone`, belongs to a `county`, and optionally belongs to a `market`.
- The class is `ZIP`, not `Zip`, because the acronym is registered. Register the
  plural too — `inflect.acronym 'ZIPs'` — or every heading reads `Zips`.
- Registering the plural renames more than headings: Rails camelizes a migration
  filename to find its class, so `create_zips.rb` must define `CreateZIPs`. It
  only breaks on a migrate from zero, which is why a reset is the real test.
- Creating a zips table always comes with a migration that backfills it: every
  ZIP, matched to the county it mostly belongs to and the main city in it.
- `time_zone` holds a Rails zone name, never an IANA identifier. The source mixes
  both, so the backfill normalizes on the way in, matching each identifier by its
  offset and DST rules: Detroit and the Kentucky zones to Eastern, Indiana's
  Eastern zones to `Indiana (East)`, Knox and Tell_City to Central, Boise to
  Mountain, Anchorage and Nome to Alaska, Honolulu to Hawaii. A test asserts no
  value survives that `ActiveSupport::TimeZone::MAPPING` does not name.

### Seed data lives in migrations, so schema.rb cannot load a database

- `config.active_record.dump_schema_after_migration = false`, so no `schema.rb`
  is ever written. Gitignoring it is not enough: it regenerates on every migrate
  and then Rails loads it into the next empty database, stamping every version at
  or below its own as already migrated — silently skipping the backfills and
  leaving the tables empty for the next foreign key to trip over.
- Build a database with `db:migrate` from zero. Never `db:schema:load`, and be
  wary of `db:prepare` for the same reason.
- `db:drop` will not drop a database with open connections and reports success
  anyway; `dropdb --force` is the reliable reset.

### Phone numbers

- A phone number is stored in a column named `phone`, holding exactly 10
  digits.
- The database enforces `null: false` and a unique index. It does not check the
  ten-digit shape — a phone is PII, so it is encrypted, and no constraint can
  read ciphertext.
- Rails is where the shape is enforced: the model includes a `Phonable` concern
  carrying both rules:

      NORTH_AMERICAN_PHONES = /\A[2-9]\d{2}[2-9]\d{6}\z/

      normalizes :phone, with: ->(phone) { phone.delete('^0-9').delete_prefix '1' }

      with_options format: { with: NORTH_AMERICAN_PHONES, message: '...' } do
        validates :phone, allow_nil: true
      end

- The concern's validation is `allow_nil`, so whether a phone is *required* is
  the including model's decision — add `presence: true` there, not in the
  concern.

### PostgreSQL, always

- When an app needs a database, it is PostgreSQL. Never MySQL, never SQLite —
  including for test-only apps like `test/dummy`, and including cases where
  SQLite would be less setup.
- Running the test suite therefore needs a PostgreSQL server. `test/test_helper`
  creates the database on first run, so `rake test` is still the only command
  needed once the server is up.

### Keep RuboCop current

- `AllCops: NewCops: enable`. Cops added by a new RuboCop release are active
  immediately rather than sitting pending; fix what they surface instead of
  pinning the version.
- `Gemspec/RequireMFA` is one of those, so the gemspec sets
  `metadata['rubygems_mfa_required']` and publishing needs MFA on the RubyGems
  account.
- `AllCops: SuggestExtensions: false`. Every run was ending with a nine-line
  advert for `rubocop-minitest` and `rubocop-rake`; we are declining both, not
  postponing them, so the suggestion is off rather than merely ignored.

### Design lives in STYLE.md

- Every decision about how a page looks — Bootstrap conventions, class choices,
  markup structure — is documented in `STYLE.md`, not here. Read that file
  before writing or editing any layout, view or partial.
- This file stays the authority for code style. Where the two overlap, `STYLE.md`
  wins on markup and `CLAUDE.md` wins on Ruby.

### Eastern time

- `config.time_zone = 'Eastern Time (US & Canada)'`. That is what `Time.zone`
  means, what a form reads, and what a timestamp renders as.
- Storage stays UTC. Never touch `config.active_record.default_timezone` — the
  database keeps UTC and Rails converts on the way in and out, so the app zone
  is a display concern only.
- A rule for apps we write. The gem never sets a host's time zone.

### Keep render lines out of the logs

- An app's log never carries Action View's `Rendering ...` and `Rendered ...`
  lines. One line per partial buries the request that matters — a 20-row table
  rendering a row partial produces 20 of them.
- Set `config.action_view.logger = nil` in `config/application.rb`. Everything
  else stays: the request, the SQL, and the `Completed 200 OK` timing line,
  which still reports view time.
- This is a rule for apps we write. The gem never touches a host's logging.

### No metaprogramming

- Never call `send` or `public_send`. Reach the data directly instead:
  `resource.attributes[column]`, not `resource.public_send column`.
- No `define_method`, `method_missing`, `instance_variable_get` / `_set`,
  `const_set`, `constantize`, or `eval` of any kind.
- The single exception is an explicit instruction to use it. Never reach for
  metaprogramming on your own initiative, and never treat the places that
  already use it as permission to add another — ask instead.

### Pass locals to partials explicitly

- A partial never reads a controller's instance variables. Declare strict
  locals on its first line — `<%# locals: (resources:, pagy:) %>` — and pass
  them at the call site: `render 'table', resources: @resources, pagy: @pagy`.
- A partial that takes no locals gets no comment at all. Never write
  `<%# locals: () %>`.
- A template rendered by an action may read instance variables. The rule is
  about partials, which should not depend on who rendered them.
- Rails enforces this: omit a declared local and the render raises instead of
  quietly rendering a blank.
- Where two branches need different locals, write `if`/`else` rather than
  `render cond ? 'a' : 'b'` — a single call cannot pass the right locals to
  both.
- The row partial is the deliberate exception, and it breaks the rule twice.
  Its record arrives under a name computed at runtime (`contact:`, `state:`),
  so the gem's own `_row` cannot declare strict locals and reads
  `local_assigns[resource_key]`. And whether it is drawing the header row or a
  body row travels in `@recourse_headers`, set by `_table` before each render,
  which `column` reads. Both were asked for; neither is a pattern to copy.

### Fewest SQL queries to render a page

- Rendering a page should issue as few queries as it can. Treat an extra query
  as a defect, not a detail.
- When checking whether a relation has records *and then looping over them*, use
  `present?` and `blank?`, never `any?` and `empty?`. `blank?` runs the
  `SELECT "contacts".*` that the loop needs anyway and caches it; `empty?` runs a
  separate `SELECT 1 ... LIMIT 1` first, so the page costs two queries instead of
  one.
- `any?` and `empty?` are still right when nothing will be looped over.
- Worth a test: assert the query count, so a later edit cannot quietly add one
  back. `test_it_reads_the_records_with_a_single_query` does this by subscribing
  to `sql.active_record`.

### Trailing comma on a multiline hash

- A multiline hash ends its last entry with a comma, so adding an entry touches
  one line instead of two:

      NAVIGATION_ICONS = {
        'States' => 'geo', 'ZIPs' => 'geo-alt-fill',
      }.freeze

- Put the closing brace on its own line. With the brace trailing the last entry
  the comma reads as `, }`, which is worse than either alternative.
- Enforced by `Style/TrailingCommaInHashLiteral` with
  `EnforcedStyleForMultiline: consistent_comma`. Not `comma` — that style
  *forbids* the comma unless every entry sits on its own line, and ours share
  lines.

### As few parentheses as possible

- Omit parentheses on a method call's arguments; keep the inner ones, where
  parsing needs them:

      Object.const_set class_name, Class.new(RecoursesController)

- Enforced by `Style/MethodCallWithArgsParentheses` with
  `EnforcedStyle: omit_parentheses`. The cop is off by default, so it needs
  `Enabled: true` as well as the style.

### I18n is deferred

- User-facing strings stay plain English for now. This suspends the baseline's
  "I18n for user-facing strings" rule until there are enough strings to be worth
  a locale file — do not add one unprompted.

### Coverage stays at 100%

- `simplecov` starts at the very top of `test/test_helper.rb`, before anything
  else is required, with `minimum_coverage 100`. Below that the suite fails.
- `skip '/test/'` leaves the dummy app out: it is a fixture, not shipped code.
  Never `add_filter` — SimpleCov deprecated it in favour of `skip`, same
  arguments and same behaviour, and it warns on every run until changed.
- `lib/recourse/version.rb` is not measured, and that is expected rather than a
  gap. The Gemfile's `gemspec` directive loads it during bundler setup, before
  SimpleCov can start. Do not add `track_files` to pull it in — it would report
  as uncovered when in fact it runs.

### Files at most 100 lines

- No code file goes over 100 lines, counting blank and comment lines. When one
  gets close, split it — extract a class, a concern, a partial, a second test
  case.
- Enforced by `rake file_length`, part of the default task. RuboCop has no
  file-length cop; `Metrics/ClassLength` and friends measure a class body, not a
  file, and skip comments and blanks by default.
- `.md`, `.txt`, `.html` and `.erb` are exempt. Prose is not code, and a view
  is markup whose length is driven by the page, not by design choices.
- Anything under `db/migrate/` is exempt. A migration that backfills a table is
  as long as the data it carries, and splitting one to satisfy a line count
  would be worse than leaving it long.

### Lines at most 100 characters

- Hard limit of 100 characters per line, enforced by RuboCop's
  `Layout/LineLength` (`Max: 100`, up from its default of 120).
- Split long strings across lines with `\` continuations rather than letting a
  line run over.
- Views are exempt — `.html` and `.erb` files may run past 100 characters,
  since a CDN URL or a long class list cannot be wrapped usefully. RuboCop does
  not lint them anyway.
- When a method call would need three lines and hanging indentation just to fit,
  hoist the long arguments into a Rails `with_options` block instead. Still
  three lines, but every line starts at a normal indent:

      with_options format: { with: SOME_PATTERN, message: 'is invalid' } do
        validates :phone, allow_nil: true
      end

### Never freeze strings

- Never write `# frozen_string_literal: true`. No file gets a magic comment,
  including generated ones — strip it from generator output.
- Never call `.freeze` on a string, constant or not. Array and hash constants
  are still worth freezing by hand.
- Where a constant only names something, prefer a symbol over a string — it is
  immutable already, so the question does not arise.
- Enforced by RuboCop: `Style/FrozenStringLiteralComment` is `never`, and
  `Style/MutableConstant` is disabled because it demands `.freeze` on string
  constants and cannot be told to skip them.

### Emails are citext

- A plaintext email column is `citext`, never `string`. An address is
  case-insensitive in practice, so `Ada@example.com` and `ada@example.com` are
  the same one, and the column type is what makes comparison and a unique index
  agree with that.
- citext arrives with its extension, so a migration runs
  `enable_extension 'citext'` before the first citext column is created.
- Nothing else is then needed: no `LOWER(email)` expression index, and no
  downcasing on the way in.
- An *encrypted* email column is not citext — the same reasoning as the rest of
  "Encrypt PII". What is stored is ciphertext, so a case-insensitive column
  compares the wrong bytes and could reject two genuinely different addresses.
  Normalize in Rails instead, always with both options:
  `encrypts :email, deterministic: true, downcase: true`.
- `deterministic: true` is not conditional on the column being unique or
  queried *today*. An address is the natural handle for finding a record, so it
  will be looked up eventually, and switching afterwards means re-encrypting
  every row. `downcase: true` is what earns the case-insensitivity the citext
  column would have given, and it is what keeps a unique index honest: without
  it two spellings of one address encrypt to two different values.
