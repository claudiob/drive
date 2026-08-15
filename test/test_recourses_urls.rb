require 'test_helper'
require 'action_dispatch/testing/integration'

# A value that is one web address and nothing else is a link on both pages that
# read it: Bootstrap's icon link in its hover style, the arrow naming the leap.
class TestRecoursesURLs < Minitest::Test
  LINK = '<a href="https://docs.example.com/setup" class="icon-link icon-link-hover">' \
         'https://docs.example.com/setup <i class="bi bi-arrow-right"></i></a>'

  def test_a_value_that_is_only_a_url_reads_as_an_icon_link
    contact = Contact.create! phone: '5559990001'
    message = Message.create! contact:, inbound: true, content: 'https://docs.example.com/setup'
    session = ActionDispatch::Integration::Session.new Rails.application

    session.get '/messages'

    assert_includes session.response.body, %(<td data-cell="Content">#{LINK}</td>)

    session.get "/messages/#{message.id}"

    assert_includes session.response.body, LINK
  ensure
    contact&.destroy
  end
end
