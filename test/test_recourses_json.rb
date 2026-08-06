require 'test_helper'
require 'action_dispatch/testing/integration'

# Every index a `recourses` line draws answers JSON as well as HTML, so a native client
# needs no controller written for it.
class TestRecoursesJSON < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
    Job.delete_all
  end

  # A job left behind holds a foreign key into locations, which another test clears.
  def teardown
    Job.delete_all
  end

  def test_an_index_answers_every_visible_column_and_where_to_find_the_record
    location = Location.create! zip: ZIP.first, city: 'Holtsville', street: '1 Main Street'
    # Shorthand first: `location:` last would run into the next line's literal.
    job = Job.create! location:, title: 'Fix the roof'

    @session.get '/jobs.json'
    row = JSON.parse(@session.response.body).sole

    assert_equal 'Fix the roof', row['title']
    assert_equal "/jobs/#{job.id}", row['path']
    # A host adds a field by overriding one method rather than the whole action.
    assert_equal 'Holtsville', row['city']
  end

  def test_a_resource_whose_show_was_never_drawn_is_given_no_path
    @session.get '/zips.json'
    row = JSON.parse(@session.response.body).first

    assert_nil row['path']
    assert_equal '00501', row['code']
  end
end
