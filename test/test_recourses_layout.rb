require 'test_helper'
require 'action_dispatch/testing/integration'

# The layout the gem falls back to, and how it finds its templates.
class TestRecoursesLayout < Minitest::Test
  def setup
    Contact.delete_all
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_serves_a_host_that_has_no_layout_of_its_own
    visit_index

    assert_includes body, 'bootstrap.min.css'
    assert_includes body, 'bootstrap.bundle.min.js'
    assert_includes body, 'family=Geist'
  end

  def test_it_loads_turbo_and_opts_no_link_out_of_prefetching
    Contact.create! phone: '5552234567'
    visit_index

    assert_includes body, '@hotwired/turbo'
    refute_includes body, 'data-turbo'
  end

  def test_it_looks_for_the_hosts_own_templates_before_its_own
    assert_equal %w[contacts recourses application], ContactsController._prefixes
  end

private

  def visit_index
    @session.get '/contacts'
  end

  def body
    @session.response.body
  end
end
