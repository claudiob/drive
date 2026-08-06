module Contacts
  # Whether a contact's conversation has been read. Swiping a row in the app posts
  # here, so the whole thread turns over in one statement rather than one per message.
  class ReadsController < ApplicationController
    # Called by the app over plain HTTP, which carries no form and so no token. Forgery
    # protection guards a cookie-authenticated browser, and there is nothing here for a
    # third-party page to ride on yet — but this has to be revisited the moment real
    # sign-in lands, since by then a session cookie will be worth stealing.
    skip_forgery_protection

    before_action :find_contact

    # Marks everything heard from this contact as read.
    def create
      @contact.messages.unread.update_all read_at: Time.current

      head :no_content
    end

    # Marks the conversation unread again, which is the newest message alone. Through a
    # subquery, since Postgres has no UPDATE ... LIMIT.
    def destroy
      newest = @contact.messages.where(inbound: true).order(created_at: :desc).limit 1
      Message.where(id: newest.select(:id)).update_all read_at: nil

      head :no_content
    end

  private

    def find_contact
      @contact = Contact.find params.expect(:contact_id)
    end
  end
end
