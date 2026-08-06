# Records when a message we sent reached the contact, which is what the tick beside an
# outgoing bubble reports. Nothing inbound is ever delivered by us, so it stays null.
class AddDeliveredAtToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :delivered_at, :datetime
  end
end
