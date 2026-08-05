# A datetime column, so the form has one of every kind a field is chosen by.
class AddAuditedAtToMarkets < ActiveRecord::Migration[8.1]
  def change
    add_column :markets, :audited_at, :datetime
  end
end
