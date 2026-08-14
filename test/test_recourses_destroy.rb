require 'test_helper'
require 'action_dispatch/testing/integration'

# Deleting a record, and what the page promises will go with it.
class TestRecoursesDestroy < Minitest::Test
  def setup
    @contact = Contact.create! phone: '5559990003', name: 'Ada'
    # Its own location, since a suite that ran in another order may have left none.
    @location = Location.create! zip: ZIP.first!, city: 'Holtsville', street: '1 Main St'
    @job = Job.create! location: @location, title: 'Fix the roof'
    @message = Message.create! contact: @contact, job: @job, inbound: true, content: 'On my way'
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def teardown
    Message.where(id: @message.id).delete_all
    Job.where(id: @job.id).delete_all
    Location.where(id: @location.id).delete_all
    Contact.where(id: @contact.id).delete_all
  end

  # A job keeps its messages, so the warning says what stays as well as what goes.
  def test_it_warns_what_a_delete_would_keep
    @session.get "/jobs/#{@job.id}/edit"
    body = @session.response.body

    assert_includes body, 'Delete Fix the roof?'
    assert_includes body, '1 message will be kept, without its job.'
    # The dialog the confirm hook fills with that warning is on the page, empty.
    assert_includes body, "id='recourse-confirm'"
  end

  # And the delete keeps that promise: the message outlives the job it was about.
  def test_it_deletes_the_record_and_keeps_what_it_said_it_would
    @session.delete "/jobs/#{@job.id}"

    assert_equal 303, @session.response.status
    assert_equal 'Job was deleted.', @session.request.flash[:notice]
    refute Job.exists?(@job.id)
    assert_nil @message.reload.job_id
  end

  # A contact takes its messages with it, and the count is of that one level: what
  # those messages reach in turn is a sentence rather than four more queries.
  def test_it_counts_a_level_of_what_goes_with_the_record
    @session.get "/contacts/#{@contact.id}/edit"

    assert_includes @session.response.body, '1 message will be deleted with it.'
    assert_includes @session.response.body, 'Anything under those goes too.'
    assert_includes @session.response.body, 'This cannot be undone.'
  end
end
