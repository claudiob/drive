require 'test_helper'
require 'action_dispatch/testing/integration'

# What `update` does with a record that saves and with one that does not.
class TestRecoursesUpdate < Minitest::Test
  def setup
    Market.delete_all
    @market = Market.create! name: 'Chicago', email: 'chi@example.com',
                             state: State.find_by!(code: 'IL')
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_saves_changes_and_returns_to_an_index_that_links_back_here
    @session.patch "/markets/#{@market.id}", params: { market: { name: 'Chicago Metro' } }

    assert_equal 'Chicago Metro', @market.reload.name
    assert_equal 'Market was updated.', @session.request.flash[:notice]

    @session.follow_redirect!

    assert_includes body, '<th scope="col">Actions</th>'
    assert_includes body, %(<a aria-label="Edit" href="/markets/#{@market.id}/edit">)
  end

  # The page names the record, by whatever its model labels one with.
  def test_it_redraws_a_form_titled_after_the_record
    @session.patch "/markets/#{@market.id}", params: { market: { email: '' } }

    assert_equal 422, @session.response.status
    assert_includes body, '<title>Chicago</title>'
    assert_includes body, "<span class='me-auto'>Market could not be updated.</span>"
  end

private

  def body
    @session.response.body
  end
end
