require 'test_helper'

# What a native client is told about the app, taken from routes.rb rather than named
# a second time. Boot-time config rendering covers these too, but only while a gem
# that renders config lives in the Gemfile; the suite says it itself.
class TestRecourseNative < Minitest::Test
  def test_the_entry_path_is_the_index_of_the_first_recourse_that_draws_one
    assert_equal 'contacts', Recourse.declared.first
    assert_equal '/contacts', Recourse.entry_path
  end

  def test_it_offers_a_tab_per_recourse_the_bar_has_room_for
    tabs = Recourse.tabs

    assert_equal Recourse::TAB_LIMIT, tabs.size
    assert_equal %w[Contacts States Counties Echoes Markets], tabs.pluck(:title)
    assert_equal({ title: 'Contacts', path: '/contacts', icon: 'person.2' }, tabs.first)
  end
end
