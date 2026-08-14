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
  # random lengths inside their length validator's bounds and their column's SQL
  # limit — a state's code is `limit: 2` with no validator, and still fits —
  # reading as words that reach past ASCII with no run longer than a word may be,
  # and a reference reading a random row of its table rather than forever the first.
  def test_it_seeds_twenty_five_rows_for_every_recoursed_model
    run_generator

    assert_file 'db/seeds/markets.rb' do |markets|
      assert_equal 25, markets.scan(/^  \{ name: '[^']+' \},$/).uniq.size
      assert_match(/[^\x00-\x7F]/, markets)
    end
    assert_file('db/seeds/messages.rb') { |messages| assert_wrapped_contents messages }
    assert_file 'db/seeds/counties.rb', /state: State\.offset\(\d+\)\.first/
    assert_file 'db/seeds/markets.rb', /rescue ActiveRecord::StatementInvalid/
    assert_shaped_strings
    assert_no_file 'db/seeds/placeholders.rb'
  end

private

  # Every shape fits its own gates: a PIN is its validator's six characters, a
  # state's code and FIPS are their columns' two, and a string named like an id —
  # the app's `uid` — is digits and nothing else.
  def assert_shaped_strings
    assert_file 'db/seeds/providers.rb', /pin: '[^' ]{6}'/
    assert_file 'db/seeds/states.rb', /code: '[^']{2}', fips: '[^']{2}'/
    assert_file 'db/seeds/apps.rb', /uid: '\d+'/
  end

  # The bare row opens the file, and every content value reads as words: nothing
  # runs past the fifteen unbroken characters a single word may be.
  def assert_wrapped_contents(messages)
    assert_match(/^  \{ content: '[^']+', inbound: (true|false), contact: Contact\./, messages)
    messages.scan(/content: '([^']+)'/).flatten.each do |content|
      refute_match(/[^ ]{16,}/, content)
    end
  end
end
