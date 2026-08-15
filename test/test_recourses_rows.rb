require 'test_helper'
require 'action_dispatch/testing/integration'

# A host names its own row: app/views/admin/sources/_row.html.erb declares every
# column itself, and the gem's table renders it in place of the generic row.
class TestRecoursesRows < Minitest::Test
  def test_a_host_row_partial_replaces_the_gems_columns
    source = Source.create! name: 'Word of mouth'
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get '/sources'
    body = session.response.body

    assert_includes body, '<td data-cell="Shouting">WORD OF MOUTH</td>'
    # The gem's own helpers still serve inside it, so the heading sorts —
    assert_includes body, 'q%5Bs%5D=name+asc'
    # — and the generic row's counter column is gone with the rest of it.
    refute_includes body, 'data-cell="Contacts"'
  ensure
    source&.destroy
  end
end
