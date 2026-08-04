# Recourse

A `routes.rb` DSL that mounts ready-made resource screens.

Add one line to `config/routes.rb` and Recourse draws the routes and serves the
controllers and views needed to browse a resource. Nothing is written into your
app — and when you want to customize a screen, you eject it.

> **Status:** early development. The API below is the intended shape and is not
> implemented yet.

## Installation

Add the gem to your Gemfile:

```ruby
gem "recourse"
```

Then run `bundle install`.

## Usage

```ruby
# config/routes.rb
Rails.application.routes.draw do
  recourses :posts
end
```

To customize a view, eject it into your app — your copy takes precedence over
the one the gem provides:

```bash
rails generate recourse:views posts
```

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
