module Contacts
  # The conversation with one contact, oldest first — what the app draws as bubbles,
  # the contact's on the left and the agent's on the right.
  class MessagesController < ApplicationController
    # Names the thread and lists it.
    def index
      contact = Contact.find params.expect(:contact_id)

      render json: {
        title: contact.display_name,
        # What the back button counts: conversations still waiting, not this one's
        # messages.
        unread: Contact.with_unread.count,
        messages: contact.messages.order(:created_at).map { |message| bubble message },
      }
    end

  private

    def bubble(message)
      {
        id: message.id, body: message.content.presence || 'Attachment',
        inbound: message.inbound, sentAt: message.created_at.iso8601,
        delivered: message.delivered_at.present?,
      }
    end
  end
end
