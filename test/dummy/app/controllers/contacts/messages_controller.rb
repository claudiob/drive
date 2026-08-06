module Contacts
  # The conversation with one contact, oldest first — what the app draws as bubbles,
  # the contact's on the left and the agent's on the right.
  class MessagesController < ApplicationController
    # Names the thread and lists it.
    def index
      contact = Contact.find params.expect(:contact_id)

      render json: {
        title: contact.display_name,
        messages: contact.messages.order(:created_at).map { |message| bubble message },
      }
    end

  private

    def bubble(message)
      {
        id: message.id, body: message.content.presence || 'Attachment',
        inbound: message.inbound, time: message.created_at.strftime('%-l:%M %p'),
      }
    end
  end
end
