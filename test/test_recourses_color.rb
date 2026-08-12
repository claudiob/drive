require 'test_helper'
require 'action_dispatch/testing/integration'

# What a host's `Recourse.color` does to the pages the gem serves.
class TestRecoursesColor < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  # Global, so every other test would see it left behind.
  def teardown
    Recourse.color = nil
  end

  def test_a_chosen_color_overrides_bootstraps_primary
    Recourse.color = 'orange'
    @session.get '/states'

    assert_includes @session.response.body, '--bs-primary-base: var(--bs-orange-500);'
    assert_includes @session.response.body,
                    '--bs-primary-fg: light-dark(var(--bs-orange-600), var(--bs-orange-400));'
  end

  def test_it_names_the_five_when_handed_anything_else
    error = assert_raises(Recourse::Error) { Recourse.color = :taupe }

    assert_equal '`Recourse.color` is one of blue, orange, purple, pink, and brown, or ' \
                 "nil for Bootstrap's own blue. It cannot be taupe.", error.message
    assert_nil Recourse.color
  end
end
