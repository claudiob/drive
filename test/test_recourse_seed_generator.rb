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
  # opening with a bare row of what a row cannot save without. Values are drawn at
  # random while generating, to each column's own shape: 25 distinct strings of
  # random lengths inside their length validator's bounds, reaching past ASCII, and
  # a reference reading a random row of its table rather than forever the first.
  def test_it_seeds_twenty_five_rows_for_every_recoursed_model
    run_generator

    assert_file 'db/seeds/markets.rb' do |markets|
      assert_equal 25, markets.scan(/^  \{ name: '[^']+' \},$/).uniq.size
      assert_match(/[^\x00-\x7F]/, markets)
    end
    assert_file 'db/seeds/messages.rb',
                /^  \{ content: '[^']+', inbound: (true|false), contact: Contact\./
    assert_file 'db/seeds/counties.rb', /state: State\.offset\(\d+\)\.first/
    assert_file 'db/seeds/providers.rb', /pin: '[^']{6}'/
    assert_no_file 'db/seeds/placeholders.rb'
  end
end
