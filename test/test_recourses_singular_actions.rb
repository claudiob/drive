require 'test_helper'
require 'integration_case'

# Where a singular resource's button stands, and which of the two verbs it offers.
class TestRecoursesSingularActions < IntegrationCase
  # A singular resource has a page of its own, so its button stands there instead --
  # and which of the two verbs it offers is the record's to say, a `has_one` answering
  # only one of them: there is nothing to add where there is already one, and nothing
  # to delete where there is none.
  def test_a_singular_resource_offers_its_action_on_its_own_page_alone
    sealed = Seal.order(:id).first.place
    unsealed = Place.where.missing(:seal).order(:id).first

    visit "/places/#{unsealed.id}/seal"

    assert_includes body, 'No seal.'
    assert_includes body, 'Add seal'
    refute_includes body, 'Delete seal'

    visit "/places/#{sealed.id}/seal"

    assert_includes body, 'Delete seal'
    refute_includes body, 'Add seal'

    # And neither of them on the place's own page, which carries the tab leading here
    visit "/places/#{sealed.id}"

    assert_includes body, %(href="/places/#{sealed.id}/seal")
    refute_includes body, %(action="/places/#{sealed.id}/seal")
  end
end
