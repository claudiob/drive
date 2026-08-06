# The Contacts tab's first screen: every contact, then the smart lists.
class ListsController < ApplicationController
  # Names and counts the four rows. Four counts for four rows, and the number of rows
  # does not grow — so this is not the N+1 the query rule is about.
  def index
    render json: {
      all: { title: 'All Contacts', count: Contact.count, path: contacts_path },
      smart: smart_lists,
    }
  end

private

  def smart_lists
    [
      smart('Unread messages', :unread, dot: Contact.with_unread.any?),
      smart('Claimed by you', :claimed, count: Contact.claimed_by(Current.agent).count),
      smart('Unclaimed', :unclaimed, count: Contact.unclaimed.count),
    ]
  end

  def smart(title, list, **badge)
    { title:, path: contacts_path(list:), **badge }
  end
end
