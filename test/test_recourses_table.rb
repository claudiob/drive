require 'test_helper'
require 'action_dispatch/testing/integration'

# How the table itself is built: classes, cell labels, and column options.
class TestRecoursesTable < Minitest::Test
  def setup
    Contact.delete_all
    @session = ActionDispatch::Integration::Session.new Rails.application
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

  # The dummy app's row passes class: 'text-nowrap' to its Created at column.
  def test_a_column_passes_its_extra_options_to_both_cells
    Contact.create! phone: '5552234567'
    visit_index

    assert_includes body, '<th scope="col" class="text-nowrap">Created at</th>'
    assert_includes body, '<td data-cell="Created at" class="text-nowrap">'
  end

private

  def visit_index
    @session.get '/contacts'
  end

  def body
    @session.response.body
  end
end
