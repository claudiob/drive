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

  # `rails generate recourse` has to reach it by that name, which is the file's
  # path and the class's namespace agreeing rather than anything declared.
  def test_it_answers_to_the_name_typed_in_a_terminal
    assert_equal Recourse::Generators::RecourseGenerator,
                 Rails::Generators.find_by_namespace('recourse')
  end

  def test_it_writes_what_resource_writes_and_a_recourses_route
    run_generator %w[widget name:string]

    assert_file 'app/models/widget.rb', /class Widget < ApplicationRecord/
    assert_file 'app/controllers/widgets_controller.rb',
                /class WidgetsController < RecoursesController/
    assert_migration 'db/migrate/create_widgets.rb', /t\.string :name/
    assert_file 'config/routes.rb', /^  recourses :widgets$/
  end

  def test_it_nests_the_route_the_way_the_resource_was_named
    run_generator %w[admin/gadget]

    assert_file 'config/routes.rb', /namespace :admin do\n    recourses :gadgets\n  end/
  end

  # Reading the USAGE is what `--help` does, and the parent generator reads it
  # without checking there is one to read.
  def test_it_has_a_usage_to_print
    assert_match 'recourses :contacts', Recourse::Generators::RecourseGenerator.desc
  end
end
