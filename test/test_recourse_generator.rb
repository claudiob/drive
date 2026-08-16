require 'test_helper'
require 'rails/generators/test_case'

# Before the generator is required, not after: a hook's default is read from this
# configuration when its class option is defined, so a generator loaded ahead of it
# has `--orm` defaulting to false and writes no model at all. `rails generate` is in
# this order too, which is why nothing in the gem has to arrange it.
Rails.application.load_generators
require 'generators/recourse/recourse_generator'

class TestRecourseGenerator < Rails::Generators::TestCase
  tests Recourse::Generators::RecourseGenerator
  destination File.expand_path('../tmp/generated', __dir__)

  def setup
    prepare_destination
    FileUtils.mkdir_p "#{destination_root}/config"
    File.write "#{destination_root}/config/routes.rb", "Rails.application.routes.draw do\nend\n"
  end

  # Reached by that name through the file's path and the class's namespace agreeing.
  def test_it_answers_to_the_name_typed_in_a_terminal
    assert_equal Recourse::Generators::RecourseGenerator,
                 Rails::Generators.find_by_namespace('recourse')
  end

  def test_it_writes_what_resource_writes_and_a_recourses_route
    generate_a_widget

    # Every column says in the model what it says in the migration, since the gem
    # reads a field's rules off the validators and never off the schema.
    assert_file 'app/models/widget.rb', /class Widget < ApplicationRecord/,
                /^  validates :name, presence: true$/,
                /^  validates :nickname, length: \{ maximum: 40 \}$/,
                /^  validates :code, uniqueness: true$/
    assert_file 'app/controllers/widgets_controller.rb',
                /class WidgetsController < RecoursesController/
    assert_migration 'db/migrate/create_widgets.rb', /t\.string :name, null: false/
    assert_file 'config/routes.rb', /^  recourses :widgets$/
  end

  # A bare row and a filled one: `name` is the only attribute the migration marks
  # `null: false`, so it is what the bare row carries and what both are found by.
  def test_it_seeds_two_rows_and_teaches_db_seeds_to_load_them
    generate_a_widget

    assert_file 'db/seeds/widgets.rb',
                /^Widget\.find_or_create_by! name: 'Bare widget', market: Market\.first$/,
                /widget\.nickname = 'Nickname'/, /widget\.quantity = 1\nend/
    assert_file 'db/seeds.rb', %r{Dir\[Rails\.root\.join\('db/seeds/\*\.rb'\)\]}
  end

  # A foreign key is required however bare the row is meant to be — `belongs_to` says
  # so — and where nothing a row must have carries a name, the filled row takes one
  # more key, so the two are found apart rather than the second finding the first.
  def test_a_bare_row_carries_the_keys_it_cannot_save_without
    run_generator %w[author name:string! email:string!]
    run_generator %w[post title content:text author:references published_on:date]

    assert_file 'db/seeds/authors.rb', /name: 'Bare author', email: 'bare@example.com'/
    assert_file 'db/seeds/posts.rb', /^Post\.find_or_create_by! author: Author\.first$/,
                /find_or_create_by!\(author: Author\.first, title: 'Everything post'\)/
  end

  # Both sides of the association a `references` attribute declares: the column on the
  # parent and the `has_many` that says what becomes of its children, and the option on
  # the child that keeps the count. A parent this app has no model for gets neither.
  def test_a_reference_counts_itself_on_the_parent
    generate_a_widget
    run_generator %w[author name:string!]
    run_generator %w[post title author:references]

    counter = 'add_column :markets, :widgets_count, :integer, default: 0, null: false'

    assert_migration 'db/migrate/create_widgets.rb', /end\n    #{counter}/
    assert_file 'app/models/widget.rb', /belongs_to :market, counter_cache: true, touch: true/
    assert_file 'app/models/post.rb', /belongs_to :author, counter_cache: true, touch: true/
    assert_file 'app/models/author.rb', /has_many :posts, dependent: :destroy/
  end

  def test_it_nests_the_route_the_way_the_resource_was_named
    run_generator %w[admin/gadget active:boolean!]

    assert_file 'config/routes.rb', /namespace :admin do\n    recourses :gadgets\n  end/
    # A boolean names its two values rather than being asked for presence, which
    # would reject `false` along with nil.
    assert_file 'app/models/admin/gadget.rb',
                /validates :active, inclusion: \{ in: \[true, false\] \}/
  end

  def generate_a_widget
    run_generator %w[widget name:string! nickname:string{40} code:string:uniq
                     market:references quantity:integer]
  end

  # `--help` reads the USAGE, and the parent never checks there is one to read.
  def test_it_has_a_usage_to_print
    assert_match 'recourses :contacts', Recourse::Generators::RecourseGenerator.desc
  end
end
