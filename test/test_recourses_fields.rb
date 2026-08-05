require 'test_helper'
require 'action_dispatch/testing/integration'

# Which field a column gets, and the HTML that constrains it.
class TestRecoursesFields < Minitest::Test
  def setup
    @session = ActionDispatch::Integration::Session.new Rails.application
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

  def test_it_marks_a_field_that_is_not_required
    visit '/contacts/new'

    assert_match %r{placeholder="Optional"[^>]*name="contact\[surname\]"}, body
    refute_match %r{placeholder="Optional"[^>]*name="contact\[phone\]"}, body
  end

  # state_id is required by `belongs_to :state`, which validates the association
  # rather than the column, so a column-only check would mark it optional.
  def test_a_belongs_to_column_counts_as_required
    visit '/counties/new'

    refute_includes body, 'placeholder="Optional"'
  end

private

  def visit(path)
    @session.get path
  end

  def body
    @session.response.body
  end
end
