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

  # Every rule the layout carries, in one bracket count. A stylesheet is inert text
  # until a browser parses it, so an unclosed comment takes every rule after it down
  # with it and no page here renders any differently — which is why this is asserted
  # rather than left to whichever test happens to look at the markup.
  def test_the_layout_ships_a_stylesheet_a_browser_can_parse
    visit '/places'

    styles = body.scan %r{<style>(.*?)</style>}m

    styles.flatten.each do |css|
      rules = css.gsub %r{/\*.*?\*/}m, ''

      refute_includes rules, '/*', 'a comment is opened and never closed'
      refute_includes rules, '*/', 'a comment is closed and never opened'
      assert_equal rules.count('{'), rules.count('}')
    end
  end
end
