require 'test_helper'
require 'integration_case'

# The one line a host says about how every page looks.
class TestRecoursesColor < IntegrationCase
  # The dummy app asks for pink, and the page says so in the tokens every button,
  # link, sorted heading and focus ring reads. A typo would otherwise write
  # `var(--bs-purpel-500)` into every page and go unnoticed until somebody looked,
  # so a name the gem does not know is refused at the point it is set — and says
  # which names there are, rather than only that this one is wrong.
  def test_a_host_picks_a_primary_colour_and_a_name_nobody_has_is_refused
    visit '/places'

    assert_includes body, '--bs-primary-base: var(--bs-pink-500);'
    error = assert_raises(Recourse::Error) { Recourse.color = :purpel }

    assert_includes error.message, 'purpel'
    assert_includes error.message, 'purple'
  ensure
    Recourse.color = :pink
  end
end
