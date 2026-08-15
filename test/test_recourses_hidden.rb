require 'test_helper'
require 'action_dispatch/testing/integration'

# A model keeps columns off its screens: App hides webhook_url with
# `def recourse_hidden = :webhook_url`, one name standing for the list — and
# Rails' own `type`, the single table inheritance column apps carry, hides by
# itself, asked by nobody.
class TestRecoursesHidden < Minitest::Test
  def test_a_model_hides_the_columns_it_names_from_the_table_and_the_form
    app = App.create! name: 'Hidden Fields'
    index = page '/apps'
    form = page "/apps/#{app.id}/edit"

    assert_includes index, 'data-cell="Name">Hidden Fields<'
    # The whole page: no column, no field — and no search term, though the
    # hidden column is indexed, which would otherwise put it in the box.
    assert_includes index, 'name="q[name_cont]"'
    ['Webhook', 'data-cell="Type"'].each { |gone| refute_includes index, gone }
    assert_includes form, 'name="app[name]"'
    ['webhook_url', 'app[type]'].each { |gone| refute_includes form, gone }
  ensure
    app&.destroy
  end

private

  def page(path)
    session = ActionDispatch::Integration::Session.new Rails.application
    session.get path

    session.response.body
  end
end
