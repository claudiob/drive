# The three helpers this app writes for the gem to find.
module TabsHelper
  # A button the routes cannot name: a sweep counts what it is about to clear, and
  # only a team with places to clear is offered one.
  def recourse_extra_actions(record)
    return [] unless record.is_a?(Team) && record.places_count.to_i.positive?

    [["Sweep #{record.places_count} places", team_sweep_path(record), :post]]
  end

  # A tab the routes cannot name: the places in the ZIP where this person's first
  # one sits, which is a page under a ZIP rather than under a person. Conditional
  # too, since a person with no places has no such ZIP -- both of the things a
  # `nav_link_to` in a hand-written layout used to be there for.
  def recourse_extra_tabs(record)
    return [] unless record.is_a?(Person) && record.places.any?

    [['Neighbours', zip_places_path(record.places.first.zip)]]
  end

  # And the way out of the sidebar, which no resource declares: a button, since
  # ending a session is never a GET.
  def recourse_extra_links
    [['Sign out', '/session', :delete]]
  end
end
