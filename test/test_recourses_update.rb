require 'test_helper'
require 'action_dispatch/testing/integration'

# What `update` does with a record that saves and with one that does not.
class TestRecoursesUpdate < Minitest::Test
  def setup
    Market.delete_all
    @market = Market.create! name: 'Chicago'
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_saves_changes_and_returns_to_an_index_that_links_back_here
    @session.patch "/markets/#{@market.id}", params: { market: { name: 'Chicago Metro' } }

    assert_equal 'Chicago Metro', @market.reload.name
    assert_equal 'Market was updated.', @session.request.flash[:notice]

    @session.follow_redirect!

    markup = '<i class="bi bi-pencil" aria-label="Edit" role="img" ' \
             'data-controller="tooltip" data-bs-placement="top" data-bs-title="Edit"></i>'

    assert_includes body, %(<th scope="col" class="recourse-actions">#{markup}</th>)
    edit = %(href="/markets/#{@market.id}/edit">)

    assert_includes body, %(<a aria-label="Edit" data-turbo-frame="_top" #{edit})
  end

  # The page names the record, by whatever its model labels one with — so what is
  # rejected has to be something other than that label, or there is nothing to name.
  def test_it_redraws_a_form_titled_after_the_record
    provider = Provider.create! name: 'Pat', phone: '2125550190', email: 'pat@example.com',
                                time_zone: 'Eastern Time (US & Canada)'
    @session.patch "/providers/#{provider.id}", params: { provider: { email: '' } }

    assert_equal 422, @session.response.status
    assert_includes body, '<title>Pat</title>'
    assert_includes body, "<span class='me-auto'>Provider could not be updated.</span>"
  ensure
    provider&.destroy
  end

private

  def body
    @session.response.body
  end
end
