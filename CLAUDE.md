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

### No code of conduct, no ideology

- Never add a `CODE_OF_CONDUCT.md`, and never link to or mention one from the
  README, gemspec, or any other file. Generators that create one (`bundle
  gem`) have their output deleted.
- Keep the codebase free of content about ethics, religion, or politics —
  including comments, docs, error messages, test fixtures, and sample data.
- `LICENSE.txt` is not covered by this: a license is a legal notice.
