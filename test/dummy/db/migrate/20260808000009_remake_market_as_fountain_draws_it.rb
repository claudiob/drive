# Trims the market back to what fountain's is — a name and its counters — and moves
# the one column that was earning its keep. A provider's email was encrypted here
# and is plaintext there, which is what a form needs to draw an email field rather
# than a password one.
class RemakeMarketAsFountainDrawsIt < ActiveRecord::Migration[8.1]
  def change
    remove_reference :markets, :state, null: false, foreign_key: true
    remove_column :markets, :email, :string
    remove_column :markets, :color, :string
    remove_column :markets, :zip, :string, limit: 5
    remove_column :markets, :opens_on, :date
    remove_column :markets, :opens_at, :time
    remove_column :markets, :audited_at, :datetime

    reversible { |direction| direction.up { plaintext_provider_emails } }
  end

private

  # The old column holds ciphertext, which is not an address in any letter case, so
  # it goes rather than being converted.
  def plaintext_provider_emails
    remove_column :providers, :email
    add_column :providers, :email, :string
    execute "update providers set email = 'provider-' || id || '@example.com'"
    change_column_null :providers, :email, false
  end
end
