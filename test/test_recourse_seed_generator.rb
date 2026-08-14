require 'test_helper'
require 'rails/generators/test_case'

Rails.application.load_generators
require 'generators/recourse/seed/seed_generator'

class TestRecourseSeedGenerator < Rails::Generators::TestCase
  tests Recourse::Generators::SeedGenerator
  destination File.expand_path('../tmp/generated_seeds', __dir__)

  def setup = prepare_destination

  # `rails generate recourse:seed` has to reach it by that name, which is the file's
  # path and the class's namespace agreeing rather than anything declared.
  def test_it_answers_to_the_name_typed_in_a_terminal
    assert_equal Recourse::Generators::SeedGenerator,
                 Rails::Generators.find_by_namespace('recourse:seed')
  end

  # One file per model the routes declare — none for a resource with no model — each
  # opening with a bare row of what a row cannot save without: presence and inclusion
  # validators, and every required belongs_to, keyed by its association. The other
  # rows mix which optional attributes are filled, in values of each column's own
  # kind: an enum cycles its words, an array wraps one, a Price reads as a Decimal.
  def test_it_seeds_twenty_five_rows_for_every_recoursed_model
    run_generator

    assert_file 'db/seeds/markets.rb', /^  \{ name: 'Name 1' \},$/
    assert_file 'db/seeds/markets.rb', /\{ name: 'Name 25' \},\n\]\.each/
    assert_file 'db/seeds/messages.rb',
                /^  \{ content: 'Content 1', inbound: false, contact: Contact\.first \},$/
    assert_file 'db/seeds/messages.rb', /media_urls: \['Media URLs 2'\]/
    assert_file 'db/seeds/jobs.rb', /status: :draft/
    assert_file 'db/seeds/providers.rb', /commission_rate: 1\.5/
    assert_file 'db/seeds.rb', %r{Dir\[Rails\.root\.join\('db/seeds/\*\.rb'\)\]}
    assert_no_file 'db/seeds/placeholders.rb'
  end
end
