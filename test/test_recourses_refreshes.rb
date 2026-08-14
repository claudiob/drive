require 'test_helper'
require 'action_dispatch/testing/integration'

# The index page refreshing itself when someone else changes one of its rows.
class TestRecoursesRefreshes < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_the_index_subscribes_to_the_stream_a_saved_record_broadcasts_on
    @session.get '/contacts'
    body = @session.response.body

    assert_includes body, '<turbo-cable-stream-source channel="Turbo::StreamsChannel"'
    # Without morph a refresh replaces the whole body; without preserve it scrolls up.
    assert_includes body, '<meta name="turbo-refresh-method" content="morph">'
    assert_includes body, '<meta name="turbo-refresh-scroll" content="preserve">'
    # The page subscribes to the very stream a saved contact broadcasts on.
    signed = body[/signed-stream-name="([^"]+)"/, 1]

    assert_equal 'contacts', Turbo.signed_stream_verifier.verified(signed)

    # And the script that turns the tag into a connection is actually servable:
    # the prefix statics sit behind it in the stack and must not swallow the path.
    @session.get '/recourse/turbo.min.js'

    assert_equal 200, @session.response.status
  end

  def test_a_change_broadcasts_a_refresh_on_that_stream
    @session.get '/contacts'
    enqueued.clear
    contact = Contact.create! name: 'Livia', phone: '2125550123'
    job = enqueued.find { |one| one[:job] == Turbo::Streams::BroadcastStreamJob }

    assert_equal 'contacts', job[:args].first
    assert_includes job[:args].last.to_s, 'refresh'
  ensure
    contact&.destroy
  end

  def test_a_model_that_opted_out_neither_subscribes_nor_broadcasts
    @session.get '/settings'

    refute_includes @session.response.body, 'turbo-cable-stream-source'
    refute Setting.recourse_broadcasting?
  end

private

  def enqueued
    ActiveJob::Base.queue_adapter.enqueued_jobs
  end
end
