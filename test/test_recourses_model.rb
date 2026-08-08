require 'test_helper'

# What a resource named after nothing answers with.
class TestRecoursesModel < Minitest::Test
  # The routes file is what needs fixing, so the message says so — rather than a
  # `NameError` surfacing from wherever the controller first asked what it lists.
  def test_a_resource_with_no_model_names_the_routes_line_to_fix
    error = assert_raises(Recourse::Error) { Recourse.model :pizzas }

    assert_equal 'You declared `recourses :pizzas` in your routes file, ' \
                 'but this app has no Pizza model.', error.message
  end
end
