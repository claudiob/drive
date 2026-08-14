# Creates the bookings table; a check constraint keeps the status column to the
# words the model admits. The street is encrypted and non-deterministic, so it
# carries no shape constraint and no index of its own.
class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_columns
    add_status_columns
    add_reference_columns
    add_check_constraint :bookings, "status IN (#{quoted Booking::STATUSES})",
                         name: 'bookings_status_known'
  end

private

  def create_columns
    create_table :bookings do |t|
      t.string :summary, null: false
      t.text :comment
      t.string :deadline, default: 'As soon as possible'
      t.string :query
      t.string :timeline
      t.string :street
      t.string :city
    end
  end

  def add_status_columns
    change_table :bookings, bulk: true do |t|
      t.string :status, default: :draft, null: false
      t.boolean :subscribed, default: true, null: false
      t.boolean :satisfied
      t.integer :quote_count, default: 1, null: false
      # Nullable on purpose: `serialize type: Array` stores an empty list as NULL.
      t.text :media_urls
      t.datetime :nominated_at
      t.datetime :notified_at
    end
  end

  def add_reference_columns
    change_table :bookings, bulk: true do |t|
      t.references :app, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.references :provider, foreign_key: true
      t.references :specialty, foreign_key: true
      t.references :zip, null: false, foreign_key: true
      t.timestamps
    end
  end

  # The words the column admits, quoted for the constraint that rejects the rest.
  def quoted(words)
    words.map { |word| "'#{word}'" }.join ', '
  end
end
