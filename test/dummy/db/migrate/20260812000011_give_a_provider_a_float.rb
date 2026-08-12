class GiveAProviderAFloat < ActiveRecord::Migration[8.1]
  # Every other number in this app is an integer or a decimal with a scale, and a
  # float is drawn and typed differently from both: `number_with_precision` with no
  # rounding to apply, and a number field with no step to hold it to. How far a
  # provider will travel is a genuine one — nobody means 12.50 miles exactly.
  def up
    add_column :providers, :service_radius, :float

    Provider.reset_column_information
    Provider.find_by(name: 'Everything Provider')&.update! service_radius: 12.5
  end

  def down
    remove_column :providers, :service_radius
  end
end
