# Coding Guidelines

**Scope:** This file is the authority for code style in this project. The
HouseAccount org-level Claude guidelines are explicitly **not** in effect here;
the baseline is standard community Ruby/Rails practice, plus the learned
preferences recorded at the bottom.

## Ruby

- Two-space indentation, no tabs. No trailing whitespace; newline at EOF.
- `snake_case` for methods/variables, `CamelCase` for classes/modules,
  `SCREAMING_SNAKE_CASE` for constants.
- Predicate methods end in `?`; mutating/dangerous variants end in `!`.
- Prefer double-quoted strings only when interpolating or escaping; single
  quotes otherwise is also fine — be consistent within a file.
- `do...end` for multi-line blocks, `{...}` for single-line blocks.
- Guard clauses over nested conditionals. Return early.
- Use `unless` for simple negatives; never `unless ... else`.
- Prefer `&.`, `||=`, `Array()`, `Hash#fetch` with defaults, and keyword
  arguments over positional args once there are more than two.
- Freeze mutable constants (`FOO = [].freeze`).
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

- Always use single-quoted strings. This supersedes the baseline bullet above
  that treats either style as acceptable.
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

### Encrypt PII

- Personal data is stored with Active Record Encryption: `encrypts :phone`,
  `:email`, `:surname`, `:street`. Suspect a column is personal? Ask before
  storing it in the clear.
- A column that is queried or must stay unique needs
  `encrypts :phone, deterministic: true`. Non-deterministic ciphertext differs
  every write, which silently defeats both a unique index and a uniqueness
  validation — they will pass while duplicates pile up.
- Encryption rules out a database check constraint on the value's shape:
  ciphertext is not ten digits. Those checks move to the model alone, and that
  is a real loss of the belt-and-braces rule, not an oversight.
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

### Phone numbers

- A phone number is stored in a column named `phone`, holding exactly 10
  digits, enforced in the database *and* in Rails.
- In the database that means a check constraint, not just a length limit:
  `add_check_constraint :table, "phone ~ '^[0-9]{10}$'"` — but only where the
  column is *not* encrypted. Encrypt it and the constraint has to go, because
  the stored value is ciphertext.
- In Rails it means the model includes a `Phonable` concern carrying both rules:

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

### Design lives in STYLE.md

- Every decision about how a page looks — Bootstrap conventions, class choices,
  markup structure — is documented in `STYLE.md`, not here. Read that file
  before writing or editing any layout, view or partial.
- This file stays the authority for code style. Where the two overlap, `STYLE.md`
  wins on markup and `CLAUDE.md` wins on Ruby.

### No metaprogramming

- Never call `send` or `public_send`. Reach the data directly instead:
  `resource.attributes[column]`, not `resource.public_send column`.
- No `define_method`, `method_missing`, `instance_variable_get` / `_set`, or
  `eval` of any kind.
- Two named exceptions, both of which *are* the gem rather than shortcuts inside
  it. Do not cite them to justify a third:
  - `Recourse::Controllers.define_missing` uses `Object.const_defined?` and
    `Object.const_set class_name, Class.new(RecoursesController)`. Supplying a
    controller the host never wrote is the whole point of `recourses`, and a
    class whose name is only known at runtime cannot be defined any other way.
  - `controller_name.classify.constantize` turns a route name into a model, in
    the controller and in the helpers. Same reason: the mapping exists only at
    runtime.
- `test/dummy`'s states migration builds a throwaway `Class.new
  ActiveRecord::Base` to insert rows without coupling to the `State` model.
  That one is avoidable, but the migration has already run, and migrations are
  never edited after shipping.

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

### Files at most 100 lines

- No code file goes over 100 lines, counting blank and comment lines. When one
  gets close, split it — extract a class, a concern, a partial, a second test
  case.
- Enforced by `rake file_length`, part of the default task. RuboCop has no
  file-length cop; `Metrics/ClassLength` and friends measure a class body, not a
  file, and skip comments and blanks by default.
- `.md`, `.txt`, `.html` and `.erb` are exempt. Prose is not code, and a view
  is markup whose length is driven by the page, not by design choices.

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
- Never call `.freeze` on a string, constant or not. This overrides the
  baseline's "freeze mutable constants" bullet for strings; array and hash
  constants are still worth freezing by hand.
- Where a constant only names something, prefer a symbol over a string — it is
  immutable already, so the question does not arise.
- Enforced by RuboCop: `Style/FrozenStringLiteralComment` is `never`, and
  `Style/MutableConstant` is disabled because it demands `.freeze` on string
  constants and cannot be told to skip them.
