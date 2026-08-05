require 'test_helper'
require 'action_dispatch/testing/integration'

# The page `recourses :contacts, only: :index` renders.
class TestRecoursesIndex < Minitest::Test
  def setup
    Contact.delete_all
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_titles_the_page_with_the_human_resource_name
    visit_index

    assert_includes body, '<title>Contacts</title>'
  end

  def test_it_renders_the_none_partial_when_there_are_no_records
    visit_index

    assert_includes body, "<p class='fg-2'>No contacts.</p>"
    refute_includes body, '<table'
  end

  def test_it_renders_the_table_partial_when_there_are_records
    Contact.create! phone: '5552234567'
    visit_index

    assert_includes body, '<table'
    refute_includes body, 'No contacts.'
  end

  # Market has one column and no code of its own beyond the model.
  def test_it_serves_a_resource_that_declares_nothing_but_a_name
    Market.delete_all
    @session.get '/markets'

    assert_equal 200, @session.response.status
    assert_includes body, "<p class='fg-2'>No markets.</p>"
  end

  def test_it_serves_a_resource_that_belongs_to_another
    @session.get '/counties'

    assert_equal 200, @session.response.status
    assert_includes body, '<th scope="col">State</th>'
    assert_includes body, 'data-cell="Fips"'
  end

  def test_the_table_has_one_row_per_record
    names = Array.new(3) { |index| "Ada #{index}" }
    names.each_with_index { |name, index| Contact.create! phone: "555223456#{index}", name: }
    visit_index

    assert_equal names.size, body.scan('<tr>').size - 1
    names.each { |name| assert_match %r{<td data-cell="Name">\s*#{name}\s*</td>}, body }
  end

private

  def visit_index
    @session.get '/contacts'
  end

  def body
    @session.response.body
  end
end
