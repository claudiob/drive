# Recourse

A `routes.rb` DSL that mounts ready-made resource screens.

Add one line to `config/routes.rb` and Recourse draws the routes and serves the
controllers and views needed to browse a resource. Nothing is written into your
app — and when you want to customize a screen, you eject it.

> **Status:** early development. The `index` action works; the other six actions
> and the eject generator are not implemented yet.

## Installation

Add the gem to your Gemfile:

```ruby
gem 'recourse'
```

Then run `bundle install`.

## Usage

```ruby
# config/routes.rb
Rails.application.routes.draw do
  recourses :contacts, only: :index
end
```

With no `ContactsController` and no templates in your app, `/contacts` now lists
the id of every `Contact`. Recourse supplies both the controller and the view.

Anything you write yourself wins. Add `app/controllers/contacts_controller.rb`
and Recourse leaves it alone; add `app/views/contacts/index.html.erb` and Rails
renders yours instead of the one the gem ships.

The usual thing to override is a single row. Add
`app/views/contacts/_row.html.erb` and Recourse's table renders yours for
`/contacts` while every other resource keeps the default:

```erb
<%# locals: (recourse: nil, heading: false) -%>
<% if heading %>
  <th scope='col'>Contact</th>
<% else %>
  <td data-cell='Contact'><%= recourse.name %></td>
<% end %>
```

The partial is rendered once for the header row with `heading: true` and no
record, then once per record with `heading: false`. It builds the cells only —
the table, the pagination and the layout stay Recourse's.

Recourse's controllers inherit from your `ApplicationController`, so its pages
render inside `app/views/layouts/application.html.erb` alongside the rest of your
app, and go through whatever that base class already does. Each page sets its
title with `content_for :title`, so put `yield :title` in that layout's `<title>`
to see it.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run
`rake test` to run the tests, or `rake` to run the tests and RuboCop. You can
also run `bin/console` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/claudiob/recourse.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
