# Signing agents in with Google

`recourses :agents` installs Google sign-in for agents. Three things are yours to
set before it works against the real Google, and one of them is easy to forget.

## 1. Limit access to your own email domain

`Unauthenticated::AgentsController::ALLOWED_DOMAIN` is the only thing standing
between your app and anyone on the internet with a Google account:

```ruby
# app/controllers/unauthenticated/agents_controller.rb
ALLOWED_DOMAIN = '@example.com'
```

Change it to your domain, keeping the leading `@` — the check is
`email.ends_with? ALLOWED_DOMAIN`, so `example.com` without the `@` would also
admit `anyone@notexample.com`. An address outside the domain is refused before any
`Agent` row is created, so a rejected sign-in leaves nothing behind.

To allow several domains, make it an array and swap the check for
`ALLOWED_DOMAINS.any? { |domain| auth.email.ends_with? domain }`.

## 2. Put your Google credentials in Rails credentials

Never in a file that gets committed:

```sh
bin/rails credentials:edit
```

```yaml
google_oauth:
  client_id: 1234567890-abcdef.apps.googleusercontent.com
  client_secret: GOCSPX-your-secret
```

`config/initializers/yt_auth.rb` reads exactly those two keys. Both come from a
**Web application** OAuth client in the Google Cloud Console, under *APIs &
Services → Credentials*.

In development you need neither: the same initializer sets
`config.mock_auth_email`, which stands in for the round trip to Google and signs you
in as that address. It is deliberately development-only — anywhere else it would
sign in anyone at all.

## 3. Register the redirect URI in the Google Cloud Console

The step that is easy to forget, and the one that produces a `redirect_uri_mismatch`
error page instead of a sign-in. In the same OAuth client, under **Authorized
redirect URIs**, add the sign-in URL for every host you use:

```
http://localhost:3000/sign_in
https://your-app.example.com/sign_in
```

They must match exactly — scheme, host, port and path. Google compares strings, so
a trailing slash or `http` where you registered `https` fails.

That path is `sign_in_url`, and it is the *callback*, not a page anyone visits
directly. It is named `sign_in` rather than fountain's `new_agent` because
`recourses :agents` already draws `new_agent` for the form that creates an agent.
Renaming it means re-registering it with Google.

## What was installed

| File | Why |
|---|---|
| `app/controllers/unauthenticated_controller.rb` | Base class for pages a signed-out visitor may reach; picks a layout with no recourse chrome. |
| `app/controllers/unauthenticated/agents_controller.rb` | The callback: exchanges Google's code, checks the domain, signs in. |
| `app/views/unauthenticated/agents/new.html.erb` | Shows an error if Google returned one. |
| `app/views/layouts/unauthenticated.html.erb` | A layout without breadcrumb or sidebar, which would raise here. |
| `app/controllers/concerns/administered.rb` | `include Administered` in a controller to require a signed-in agent. |
| `app/controllers/agents/sessions_controller.rb` | Signing out. |
| `app/models/current.rb` | `Current.agent` for the length of a request. |
| `config/initializers/yt_auth.rb` | Where the credentials are read. |

## Requiring a signed-in agent

Nothing is protected yet. Add it where you want it:

```ruby
class ApplicationController < ActionController::Base
  include Administered
end
```

A signed-out visitor is then sent to Google, and returned to the page they asked
for — `Administered` stores it in `session[:return_to]` on the way out.
