require 'test_helper'
require 'action_dispatch/testing/integration'

# The new page the gem serves, and the form partial it renders.
class TestRecoursesForm < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
  end

  def test_it_titles_the_page_after_the_resource
    visit '/counties/new'

    assert_equal 200, @session.response.status
    assert_includes body, '<title>New county</title>'
  end

  # The field names prove `new` set @county: the form is built from that record.
  def test_it_posts_to_the_index_path_with_a_field_per_editable_column
    visit '/counties/new'

    assert_includes body, '<form action="/counties" accept-charset="UTF-8" method="post">'
    %w[fips name state_id].each { |column| assert_includes body, %(name="county[#{column}]") }
  end

  def test_it_leaves_out_the_columns_a_user_cannot_set
    visit '/counties/new'

    %w[id created_at updated_at].each do |column|
      refute_includes body, %(name="county[#{column}]")
    end
  end

  def test_it_labels_each_field_the_way_the_table_heads_it
    visit '/counties/new'

    assert_includes body, '<label class="form-label" for="county_fips">Fips</label>'
    assert_includes body, '<label class="form-label" for="county_state_id">State</label>'
  end

  def test_it_offers_a_button_to_submit
    visit '/counties/new'

    assert_includes body, 'class="btn btn-solid theme-primary"'
    assert_includes body, 'value="Create County"'
  end

  def test_it_picks_a_field_type_from_what_the_column_holds
    visit '/markets/new'

    assert_includes body, 'type="email" name="market[email]"'
    assert_includes body, 'type="color" name="market[color]"'
    assert_includes body, 'type="date" name="market[opens_on]"'
    assert_includes body, 'type="time" name="market[opens_at]"'
    assert_includes body, 'type="datetime-local" name="market[audited_at]"'
    assert_includes body, 'type="text" name="market[name]"'
  end

  def test_it_constrains_a_digits_only_column_in_the_browser
    visit '/markets/new'

    assert_includes body, 'maxlength="5" pattern="\d{5}" inputmode="numeric"'
  end

  # ZIP is an acronym, so the inflector spells the label rather than 'Zip'.
  def test_it_spells_an_acronym_in_the_label
    visit '/markets/new'

    assert_includes body, '>ZIP</label>'
  end

  def test_it_masks_an_encrypted_column
    visit '/contacts/new'

    %w[phone email surname].each do |column|
      assert_includes body, %(type="password" name="contact[#{column}]")
    end
  end

private

  def visit(path)
    @session.get path
  end

  def body
    @session.response.body
  end
end
