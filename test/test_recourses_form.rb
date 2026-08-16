require 'test_helper'
require 'integration_case'

# The form `new` and `edit` draw, and the rules each field carries into the browser.
class TestRecoursesForm < IntegrationCase
  # One pass over a form whose model has a column of every kind. Every rule here is
  # read off a validator rather than off the schema: a length becomes `maxlength`, a
  # format becomes `pattern`, a numericality becomes a numeric keyboard and a step,
  # and a column with no validator saying otherwise is simply optional.
  def test_each_field_carries_the_rules_its_own_validators_state
    visit "/places/#{Place.order(:id).first.id}/edit"

    # An integer steps by one; a float by anything; a decimal by its own scale, and
    # stops at what its precision can hold.
    assert_includes body, 'inputmode="numeric" required="required" step="1" type="number"'
    assert_includes body, 'step="any" type="number"'
    assert_includes body, 'step="0.01" max="999999.99"'
    # A price and a percentage are decimals of their own precision, so their own max.
    assert_includes body, 'max="99999999.99"'
    assert_includes body, 'max="99.99"'
    # A format validator with no sample to show says the pattern itself.
    assert_includes body, 'pattern="[a-z0-9]+(-[a-z0-9]+)*"'
    # And one with a sample says the sample instead.
    assert_includes body, 'title="Please match the format 555-555-5555"'
    assert_includes body, 'type="date"'
    assert_includes body, 'type="datetime-local"'
    # A text column is a textarea, and an optional field says so where it stands.
    assert_includes body, '<textarea class="form-control" placeholder="Optional"'
    # A non-null boolean is a checkbox with the hidden zero beside it.
    assert_includes body, '<input name="place[active]" type="hidden" value="0" />'
    # And a typed reference opens on the record's own label, so an edit that
    # changes something else does not have to retype this one to save.
    assert_includes body, %(value="#{Place.order(:id).first.msa.code}")
  end

  # A foreign key is picked or typed by what the other table can offer: three teams
  # fit in a menu, and 101 MSAs do not — so one is a combobox and the other is a
  # field asking for the label itself, under the foreign key's own name, carrying
  # that label's length so the browser can hold it to five characters.
  def test_a_reference_is_a_menu_or_a_field_by_what_it_points_at
    visit '/places/new'

    assert_includes body, 'name="place[msa_id]"'
    # The label's own length and format, since that is what is being typed — and an
    # example read off the pattern, so the field names the shape it wants rather
    # than only reporting that what was typed is wrong.
    assert_includes body, 'maxlength="5" minlength="5" pattern="[A-Z]\d{4}"'
    assert_includes body, 'title="Please match the format A0000"'
    assert_includes body, %(data-bs-name='place[team_id]' data-controller='combobox')
    # The menu holds the labels, not the ids, and the typed one holds no menu at all.
    assert_includes body, 'Blue Crew'
    refute_includes body, 'M0001'
  end

  # A key that may be nothing has to be settable back to it, which a menu of records
  # cannot otherwise say. The item carries an empty value of its own, since the
  # plugin builds its hidden input from whichever item is selected — and only where
  # the model permits it: a required key offers no way to leave itself empty.
  def test_only_an_optional_menu_offers_a_way_to_choose_nothing
    visit "/places/#{Place.order(:id).first.id}/edit"

    assert_includes menu_for('place[person_id]'), %(data-bs-value='' aria-selected='false')
    assert_includes menu_for('place[person_id]'), '<span>None</span>'
    refute_includes menu_for('place[team_id]'), %(data-bs-value='' )
    # `status` is `null: false` and the model says so, so it is required too.
    refute_includes menu_for('place[status]'), %(data-bs-value='' )
  end

private

  # One combobox's menu, from its toggle to the end of its options.
  def menu_for(name)
    body[/data-bs-name='#{Regexp.escape name}'.*?combobox-no-results/m]
  end
end
