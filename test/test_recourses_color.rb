require 'test_helper'
require 'integration_case'

# The two lines a host says about how every page looks.
class TestRecoursesColor < IntegrationCase
  # The dummy app asks for pink, and the page says so in the tokens every button,
  # link, sorted heading and focus ring reads. A typo would otherwise write
  # `var(--bs-purpel-500)` into every page and go unnoticed until somebody looked,
  # so a name the gem does not know is refused at the point it is set — and says
  # which names there are, rather than only that this one is wrong.
  def test_a_host_picks_a_primary_colour_and_a_name_nobody_has_is_refused
    visit '/places'

    assert_includes body, '--bs-primary-base: var(--bs-pink-500);'
    # The ink a solid fill's label is drawn in. Asserted rather than left to coverage:
    # the line runs whichever token it returns, so a page stays green while a button
    # goes illegible — white on Solarized's pink at 4.21:1, its darkest neutral at 2.83.
    assert_includes body, '--bs-primary-contrast: var(--bs-white);'
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

  # The dummy app asks for Solarized, so the page links its palette and the engine
  # serves it. The palette is a file rather than a block in the page, so what proves it
  # arrived is fetching it and finding Solarized's own paper. A name nobody ships would
  # otherwise ask the browser for a stylesheet that is not there and go unnoticed until
  # somebody looked at a page, so it is refused where it is set.
  def test_a_host_picks_a_palette_and_a_name_nobody_ships_is_refused
    visit '/places'

    assert_includes body, '<link rel="stylesheet" href="/recourse/themes/solarized.css">'
    visit '/recourse/themes/solarized.css'

    assert_includes body, '--bs-white: #fdf6e3;'
    error = assert_raises(Recourse::Error) { Recourse.theme = :solarised }

    assert_includes error.message, 'solarised'
    assert_includes error.message, 'solarized'
  ensure
    Recourse.theme = :solarized
  end
end
