require 'test_helper'
require 'action_dispatch/testing/integration'

# A value reads the same in a table as on the record's own page: one web address
# and nothing else is Bootstrap's icon link in its hover style, the arrow naming
# the leap, and a boolean is that icon on both rather than the word on one.
class TestRecoursesURLs < Minitest::Test
  LINK = '<a href="https://docs.example.com/setup" class="icon-link icon-link-hover">' \
         'https://docs.example.com/setup <i class="bi bi-arrow-right"></i></a>'

  # Asserted on both pages because one ladder now draws both, and because the two
  # ran apart until it did: the table spelled `true` where the record drew a check.
  BOOLEAN = '<i class="bi bi-check" aria-label="true"></i>'

  def test_a_value_that_is_only_a_url_reads_as_an_icon_link
    contact = Contact.create! phone: '5559990001'
    message = Message.create! contact:, inbound: true, content: 'https://docs.example.com/setup'

    assert_page '/messages', %(<td data-cell="Content">#{LINK}</td>),
                %(<td data-cell="Inbound">#{BOOLEAN}</td>)
    assert_page "/messages/#{message.id}", LINK, BOOLEAN
  ensure
    contact&.destroy
  end

private

  def assert_page(path, *expected)
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get path

    expected.each { |markup| assert_includes session.response.body, markup }
  end
end
