# Creates the providers table; a check constraint keeps the team_size column to
# the words the model admits. Email, phone and PIN are encrypted, so none of the
# three carries a shape constraint in the database — that is the model's job.
class CreateProviders < ActiveRecord::Migration[8.1]
  def change
    create_columns
    add_status_columns
    add_financial_columns
    add_history_columns
    add_check_constraint :providers, "team_size IN (#{quoted Provider::TEAM_SIZES})",
                         name: 'providers_team_size_known'
  end

private

  def create_columns
    create_table :providers do |t|
      t.string :name, null: false, index: true
      t.string :email
      t.string :phone, null: false, index: { unique: true }
      t.string :pin
    end
  end

  def add_status_columns
    change_table :providers, bulk: true do |t|
      t.boolean :active, default: true, null: false
      t.boolean :insured, default: true, null: false
      t.boolean :subscribed, default: true, null: false
      t.string :time_zone, null: false
      t.string :team_size
    end
  end

  def add_financial_columns
    change_table :providers, bulk: true do |t|
      t.decimal :commission_rate, precision: 4, scale: 2, default: 15.0, null: false
      t.string :commission_type, limit: 1, default: '%', null: false
      t.decimal :hourly_rate, precision: 10, scale: 2
      t.decimal :minimum_price, precision: 10, scale: 2
      t.decimal :review_rating, precision: 6, scale: 2
      t.integer :review_number
    end
  end

  def add_history_columns
    change_table :providers, bulk: true do |t|
      t.date :signed_on
      t.string :signed_by
      t.datetime :paused_until
      t.references :franchise, foreign_key: true
      t.integer :bookings_count, default: 0, null: false
      t.timestamps
    end
  end

  # The words the column admits, quoted for the constraint that rejects the rest.
  def quoted(words)
    words.map { |word| "'#{word}'" }.join ', '
  end
end
