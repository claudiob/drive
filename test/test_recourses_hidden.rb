require 'test_helper'
require 'action_dispatch/testing/integration'

# A model keeps columns off its screens: App hides webhook_url with
# `def recourse_hidden = :webhook_url`, one name standing for the list.
class TestRecoursesHidden < Minitest::Test
  def test_a_model_hides_the_columns_it_names_from_the_table_and_the_form
    app = App.create! name: 'Hidden Fields'
    session = ActionDispatch::Integration::Session.new Rails.application

    session.get '/apps'

    assert_includes session.response.body, 'data-cell="Name">Hidden Fields<'
    refute_includes session.response.body, 'Webhook'

    session.get "/apps/#{app.id}/edit"

    assert_includes session.response.body, 'name="app[name]"'
    refute_includes session.response.body, 'webhook_url'
  ensure
    app&.destroy
  end
end
