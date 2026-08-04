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

    assert_includes body, "<table class='table table-hover'>"
    refute_includes body, 'No contacts.'
  end

  def test_the_table_shows_every_column_that_is_not_encrypted
    Contact.create! phone: '5552234567'
    visit_index

    ['Id', 'Phone', 'Name', 'Surname', 'Created at', 'Updated at'].each do |heading|
      assert_includes body, "<th scope='col'>#{heading}</th>"
    end
  end

  def test_the_table_formats_a_phone_number_for_reading
    Contact.create! phone: '5552234567'
    visit_index

    assert_includes body, '<td>555-223-4567</td>'
    refute_includes body, '<td>5552234567</td>'
  end

  def test_the_table_leaves_out_encrypted_columns
    Contact.create! phone: '5552234567', email: 'ada@example.com'
    visit_index

    refute_includes body, 'Email'
    refute_includes body, 'ada@example.com'
  end

  def test_the_gems_layout_serves_a_host_that_has_none
    visit_index

    assert_includes body, 'bootstrap.min.css'
    assert_includes body, 'bootstrap.bundle.min.js'
    assert_includes body, 'family=Geist'
  end

  def test_it_looks_for_the_hosts_own_templates_before_its_own
    assert_equal %w[contacts recourses application], ContactsController._prefixes
  end

  def test_the_table_has_one_row_per_record
    ids = Array.new(3) { |index| Contact.create!(phone: "555223456#{index}").id }
    visit_index

    assert_equal ids.size, body.scan('<tr>').size - 1
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
