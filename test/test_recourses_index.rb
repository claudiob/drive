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

  def test_the_table_carries_the_classes_the_style_guide_requires
    Contact.create! phone: '5552234567'
    visit_index

    classes = body[/<table class='([^']*)'/, 1].split

    ['table', 'table-hover', 'sm:table-stacked'].each do |name|
      assert_includes classes, name
    end
  end

  def test_every_cell_is_labelled_so_the_stacked_layout_reads
    Contact.create! phone: '5552234567'
    visit_index

    assert_equal body.scan('<td ').size, body.scan('data-cell=').size
    assert_includes body, 'data-cell="Name"'
  end

  # /counties has no row partial of its own, so it shows every column the model
  # exposes. /contacts cannot answer this: the dummy app overrides its row.
  def test_the_generic_table_shows_every_column_that_is_not_encrypted
    @session.get '/counties'

    ['Id', 'Fips', 'Name', 'State', 'Created at', 'Updated at'].each do |heading|
      assert_includes body, "<th scope=\"col\">#{heading}</th>"
    end
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
    names.each { |name| assert_includes body, "<td data-cell=\"Name\">#{name}</td>" }
  end

private

  def visit_index
    @session.get '/contacts'
  end

  def body
    @session.response.body
  end
end
