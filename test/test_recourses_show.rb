require 'test_helper'
require 'integration_case'

# A record's own page, and the card the nested indexes hang off it by.
class TestRecoursesShow < IntegrationCase
  # One pass over a record carrying a value of every kind, each read out as what its
  # column holds rather than as what the database keeps: a price wears its currency
  # and a percentage its sign, both decimals underneath; a float keeps its own
  # precision; a date and a time are `time` tags a browser can localize; an enum is
  # a badge and a boolean is the word, not an icon; a URL is a link.
  def test_it_reads_out_a_value_of_every_kind_in_the_shape_its_column_earns
    visit "/places/#{Place.order(:id).first.id}"

    assert_includes body, '$20.00'
    assert_includes body, '5.25%'
    assert_includes body, '100.25'
    assert_includes body, '0.500'
    assert_includes body, '415-555-0000'
    assert_includes body, '<time datetime="2026-01-01">Jan 1, 2026</time>'
    assert_includes body, 'datetime="2026-06-01T09:30:00-04:00"'
    assert_includes body, '<span class="badge">draft'
    # Words rather than icons, and the reference read as its label either way.
    assert_includes body, 'true'
    assert_includes body, 'false'
    assert_includes body, '90001'
    assert_includes body, 'Blue Crew'
    assert_includes body, '<a href="https://place-1.example.com"'
  end

  # The card a record's own page sits in: its Show tab first, then one tab per index
  # nested under it, in the order routes.rb nested them rather than the order the
  # associations were declared. A counter cache decides how a tab reads and never
  # whether it is there — Places carries one, Memos does not.
  def test_the_card_tabs_follow_the_routes_and_read_by_what_is_counted
    person = Person.order(:id).first
    visit "/people/#{person.id}"

    assert_includes body, %(href="/people/#{person.id}/places">)
    assert_includes body, "#{person.places_count} places"
    assert_includes body, %(href="/people/#{person.id}/memos">)
    assert_includes body, '</i> Memos</a>'
    # The tab order is the routes file's: places was nested first. By href, since a
    # bare action's button carries a path of its own before the tabs are drawn.
    assert_operator body.index(%(href="/people/#{person.id}/places")), :<,
                    body.index(%(href="/people/#{person.id}/memos"))
  end
end
