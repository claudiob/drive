# Creates the messages table: what was said, or what was sent instead of words.
class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.text :content
      # No `null: false`: the model's `serialize type: Array` stores an empty list
      # as NULL and reads NULL back as [], so the coder is what keeps it an Array.
      t.text :media_urls
      t.boolean :inbound, null: false
      t.references :contact, null: false, foreign_key: true
      t.references :job, foreign_key: true

      t.timestamps
    end
  end
end
