require 'test_helper'
require 'integration_case'

# The table `recourses` draws, and the chrome around it.
class TestRecoursesIndex < IntegrationCase
  # One pass over a page carrying every kind of column: a heading that sorts and one
  # that does not, a counter headed by what it counts, a foreign key read as a label,
  # and the columns no table shows — the id, the ciphertext, the readonly and the
  # hidden. A `data-cell` carries the title as text, so a narrow screen labels the
  # cell with a word rather than with a link.
  def test_the_table_shows_every_column_that_earns_a_place_and_no_other
    visit '/places'

    assert_includes body, 'href="/places?q%5Bs%5D=name+asc">Name</a></th>'
    # Indexed, so it sorts; `Capacity` is not, so it is a heading and nothing more.
    assert_includes body, '<th scope="col">Capacity</th>'
    assert_includes body, '<td data-cell="Team">Blue Crew</td>'
    # Its own status, as the word the column holds rather than a number.
    assert_includes body, '<td data-cell="Status"><span class="badge">draft</span></td>'
    # `Details` among them: a JSON payload is one value as wide as the page, so no
    # table draws one until a model names it back with `recourse_displayed`.
    %w[Id Secret Notes Webhook Details].each do |column|
      refute_includes body, %(data-cell="#{column}")
    end
    # The whole row, in the bands a column's kind puts it in: the squares and the links
    # that open the record, then what state it is in, its flags, whose it is, what it
    # says, the long ones, when it happened, and the two Rails keeps. Inside a band the
    # order is the table's own, which is what leaves `capacity rating area` reading as
    # the schema wrote it. Asserted whole, so a band moving is a failure rather than a
    # surprise noticed on a page.
    headings = body.scan(/data-cell="([^"]+)"/).flatten.uniq

    assert_equal [
      'Bookmark', 'Show', 'Edit', 'Status', 'Active', 'Verified', 'ZIP code', 'Team',
      'Person', 'Name', 'Slug', 'Capacity', 'Rating', 'Area', 'Hourly rate',
      'Commission rate', 'Phone', 'Website', 'About', 'Opens on', 'Audited at',
      'Created at', 'Updated at',
    ], headings
  end

  # A counter is headed with the icon of what it counts, named for a reader who
  # cannot see it, and sorts; its cells carry the figure, linking out of the frame to
  # the index nested under that row — and each says what it counts twice over, in a
  # tooltip for the row where the heading has scrolled away and in a label for the
  # reader who would otherwise hear only `3`.
  def test_a_counter_column_is_an_icon_over_a_figure_that_links
    person = Person.order(:id).first
    visit '/people'
    icon = '<i class="bi bi-building" aria-label="Places" role="img" ' \
           'data-controller="tooltip" data-bs-placement="top" data-bs-title="Places"></i>'

    assert_includes body, %(q%5Bs%5D=places_count+asc">#{icon}</a></th>)
    assert_includes body, %(<a aria-label="3 Places" data-turbo-frame="_top" ) +
                          %(data-controller="tooltip" data-bs-placement="top" ) +
                          %(data-bs-title="Places" href="/people/#{person.id}/places">3</a>)
  end

  # A sidebar link answers to a letter of its own title, and the first one free:
  # Places and People both start with P, and Places is declared first. The icon
  # beside each is the concept its model names — nothing says the word `Memos`
  # draws a sticky, the model's own name does.
  def test_each_sidebar_entry_marks_the_letter_that_reaches_it
    visit '/places'

    assert_includes body, '<span class="recourse-key">P</span>laces'
    assert_includes body, 'P<span class="recourse-key">e</span>ople'
    # Declared outside the module, and linking where its own routes were drawn.
    assert_includes body, 'href="/memos"'
    # An acronym keeps its capitals in a title the gem pluralized itself.
    assert_includes body, '<span class="recourse-key">Z</span>IPs'
  end

  # Twenty to a page, the count delimited, and the nav only where there is a second
  # page to reach. Exempt from "as few tests as coverage needs": the same lines run
  # whether the figures are right or wrong.
  def test_it_paginates_at_twenty_rows_and_says_what_it_is_showing
    visit '/zips'

    assert_includes body, 'Displaying items 1-20 of 101 in total'
    assert_includes body, 'href="/zips?page=2"'
    # Four teams fit on one page, so that page says so and offers no nav.
    visit '/teams'

    assert_includes body, 'Displaying 4 items'
    refute_includes body, 'pagination'
  end
end
