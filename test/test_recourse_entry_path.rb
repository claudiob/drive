require 'test_helper'

# The path a client opens on when it needs one, taken from routes.rb rather than
# named a second time. Boot-time config rendering covers this line too, but only
# while a gem that renders config lives in the Gemfile; the suite says it itself.
class TestRecourseEntryPath < Minitest::Test
  def test_it_is_the_index_of_the_first_recourse_that_draws_one
    assert_equal 'contacts', Recourse.declared.first
    assert_equal '/contacts', Recourse.entry_path
  end
end
