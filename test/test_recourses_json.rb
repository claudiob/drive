require 'test_helper'
require 'action_dispatch/testing/integration'

# Every index a `recourses` line draws answers JSON as well as HTML, so a native client
# needs no controller written for it.
class TestRecoursesJSON < Minitest::Test
  # Valid and unlikely to collide: the shape `Phonable` insists on.
  PHONE = '5559998888'

  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
    Job.delete_all
  end

  # A job left behind holds a foreign key into locations, which another test clears,
  # and a contact would throw off the one that counts a page of them.
  def teardown
    Job.delete_all
    Contact.where(phone: PHONE).delete_all
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

  def test_it_answers_a_created_record_and_where_to_find_it
    @session.post '/contacts.json', params: { contact: { phone: PHONE, name: 'Kit' } }
    record = JSON.parse @session.response.body

    assert_equal 201, @session.response.status
    assert_equal 'Kit', record['name']
    assert_equal "/contacts/#{Contact.find_by(phone: PHONE).id}", record['path']
  end

  def test_it_answers_the_errors_of_a_record_it_would_not_save
    @session.post '/contacts.json', params: { contact: { phone: '' } }

    assert_equal 422, @session.response.status
    # Full sentences, not bare reasons: an alert repeats these back as they are.
    assert_includes JSON.parse(@session.response.body).fetch('errors').fetch('phone'),
                    "Phone can't be blank"
  end

  def test_a_resource_whose_show_was_never_drawn_is_given_no_path
    @session.get '/zips.json'
    row = JSON.parse(@session.response.body).first

    assert_nil row['path']
    assert_equal '00501', row['code']
  end
end
