# Records when a message was read, and indexes the two questions the app asks of it:
# the latest message per contact, and whether any of theirs is still unread.
class AddReadAtToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :read_at, :datetime

    add_index :messages, %i[contact_id created_at], order: { created_at: :desc }
    add_index :messages, :contact_id, where: 'inbound and read_at is null',
                                      name: 'index_messages_on_unread'

    # The composite index leads with contact_id, so the one `t.references` created is
    # now redundant, and a redundant index is paid for on every write. Named, because
    # the partial index above also covers that column and `remove_index` cannot choose.
    remove_index :messages, :contact_id, name: :index_messages_on_contact_id
  end
end
