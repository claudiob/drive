require 'test_helper'
require 'action_dispatch/testing/integration'

# What a host's `Recourse.color` does to the pages the gem serves.
class TestRecoursesColor < Minitest::Test
  def setup
    @color = Recourse.color
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  # Put back rather than cleared: it is global, and the dummy app's initializer set
  # it, so clearing would leave every test that ran after this one in another app.
  def teardown
    Recourse.color = @color
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
    assert_equal @color, Recourse.color
  end
end
