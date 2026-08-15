require 'test_helper'
require 'action_dispatch/testing/integration'

# The card at the top of a record's pages, naming each page the record has.
class TestRecoursesCard < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  # A look before a change, each behind the icon its row link carries, and the one
  # being read marked as current.
  def test_the_card_names_both_pages_a_record_has
    provider = Provider.find_by! name: 'Everything Provider'
    @session.get "/providers/#{provider.id}"
    body = @session.response.body
    showing = %(href="/providers/#{provider.id}"><i class="bi bi-eye"></i> Show</a>)

    assert_includes body, %(<a class="nav-link active" aria-current="page" #{showing})
    assert_includes body, %(<i class="bi bi-pencil-square"></i> Edit</a>)
  end

  # A nested index earns its tab from the route alone: no counter cache behind
  # agents' settings, so the tab is the bare capitalized name, no figure before it.
  def test_an_uncounted_nested_index_reads_as_the_bare_name
    agent = Agent.create! email: 'tabs@example.com'
    @session.get "/agents/#{agent.id}"

    assert_includes @session.response.body, %(<i class="bi bi-gear"></i> Settings</a>)
  ensure
    agent&.destroy
  end
end
