# Messages: the Bootstrap console for a browser, and one row per conversation in the
# app, the way Apple's Messages lists threads rather than messages. That is a payload
# of its own rather than a row-shaped change, so it replaces the whole index.
class MessagesController < RecoursesController
  # How a conversation's date reads in the list: the day for anything older than today.
  DATE_FORMAT = '%-m/%-d/%y'

private

  def index_json
    Message.conversations.map { |message| thread message }
  end

  def thread(message)
    contact = message.contact

    {
      id: message.id, author: contact.display_name, initials: contact.initials,
      preview: preview(message), date: message.created_at.strftime(DATE_FORMAT),
      unread: message.unread_count.positive?, path: contact_messages_path(contact),
      readPath: contact_read_path(contact),
    }
  end

  # A message may carry media and no words at all, which the model allows on purpose.
  def preview(message)
    message.content.presence || 'Attachment'
  end
end
