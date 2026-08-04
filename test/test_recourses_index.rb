require 'test_helper'
require 'action_dispatch/testing/integration'

# The page `recourses :contacts, only: :index` renders.
class TestRecoursesIndex < Minitest::Test
  def setup
    Contact.delete_all
    @session = ActionDispatch::Integration::Session.new(Rails.application)
  end

  def test_it_titles_the_page_with_the_human_resource_name
    visit_index

    assert_includes body, '<title>Contacts</title>'
  end

  def test_it_renders_the_none_partial_when_there_are_no_records
    visit_index

    assert_includes body, '<p>No contacts.</p>'
    refute_includes body, '<table>'
  end

  def test_it_renders_the_table_partial_when_there_are_records
    Contact.create!(phone: '5552234567')
    visit_index

    assert_includes body, '<table>'
    refute_includes body, 'No contacts.'
  end

  def test_the_table_has_a_single_id_column
    Contact.create!(phone: '5552234567')
    visit_index

    assert_equal 1, body.scan('<th>').size
    assert_includes body, '<th>ID</th>'
  end

  def test_the_table_has_one_row_per_record
    ids = Array.new(3) { |index| Contact.create!(phone: "555223456#{index}").id }
    visit_index

    assert_equal ids.size, body.scan('<td>').size
    ids.each { |id| assert_includes body, "<td>#{id}</td>" }
  end

private

  def visit_index
    @session.get '/contacts'
  end

  def body
    @session.response.body
  end
end
