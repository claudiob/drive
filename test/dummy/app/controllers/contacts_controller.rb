# Contacts: the Bootstrap console for a browser, and the alphabetical list the app
# draws natively. Its payload is not a flat list of records — the screen wants
# sections and a card of its own, and every contact rather than a page, since an A–Z
# index over one page would scrub to letters that are not in it.
class ContactsController < RecoursesController
  before_action :find_resource, only: :show

  # Shows one contact.
  def show; end

private

  def index_json
    { myCard: card(my_card), sections: sections }
  end

  def listed
    case params[:list]
      when 'unread' then Contact.with_unread
      when 'claimed' then Contact.claimed_by Current.agent
      when 'unclaimed' then Contact.unclaimed
      else Contact.all
    end
  end

  def sections
    listed.alphabetical.group_by(&:initial).map do |letter, contacts|
      { title: letter, contacts: contacts.map { |contact| card contact } }
    end
  end

  # The signed-in agent's own contact, found by the email they share. Deterministic
  # encryption is what makes that lookup possible at all.
  def my_card
    Contact.find_by email: Current.agent.email if Current.agent
  end

  def card(contact)
    return unless contact

    {
      id: contact.id, name: contact.display_name, initials: contact.initials,
      first: contact.name, last: contact.surname,
      phone: ActiveSupport::NumberHelper.number_to_phone(contact.phone),
      path: contact_path(contact),
    }
  end
end
