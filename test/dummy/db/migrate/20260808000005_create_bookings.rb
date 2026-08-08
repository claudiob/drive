# Creates the bookings table, and the Postgres type its status column draws
# from. The street is encrypted and non-deterministic, so it carries no shape
# constraint and no index of its own.
class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_enum :booking_status, Booking::STATUSES
    create_columns
    add_status_columns
    add_reference_columns
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
      t.enum :status, enum_type: :booking_status, default: :draft, null: false
      t.boolean :subscribed, default: true, null: false
      t.boolean :satisfied
      t.integer :quote_count, default: 1, null: false
      t.text :media_urls, array: true, default: [], null: false
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
end
