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

Pages render without a layout unless you give them one. Add
`app/views/layouts/recourses.html.erb` and every Recourse page renders inside it
— that is also where to `yield :title`, which each page sets to the name of the
resource.

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
