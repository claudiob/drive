# Creates the states table and backfills the official United States list.
class CreateStates < ActiveRecord::Migration[8.1]
  # Postal code, FIPS code and name, from https://www2.census.gov/geo/docs/reference/state.txt
  STATES = [
    ['AL', '01', 'Alabama'], ['AK', '02', 'Alaska'], ['AZ', '04', 'Arizona'],
    ['AR', '05', 'Arkansas'], ['CA', '06', 'California'], ['CO', '08', 'Colorado'],
    ['CT', '09', 'Connecticut'], ['DE', '10', 'Delaware'], ['DC', '11', 'District of Columbia'],
    ['FL', '12', 'Florida'], ['GA', '13', 'Georgia'], ['HI', '15', 'Hawaii'],
    ['ID', '16', 'Idaho'], ['IL', '17', 'Illinois'], ['IN', '18', 'Indiana'],
    ['IA', '19', 'Iowa'], ['KS', '20', 'Kansas'], ['KY', '21', 'Kentucky'],
    ['LA', '22', 'Louisiana'], ['ME', '23', 'Maine'], ['MD', '24', 'Maryland'],
    ['MA', '25', 'Massachusetts'], ['MI', '26', 'Michigan'], ['MN', '27', 'Minnesota'],
    ['MS', '28', 'Mississippi'], ['MO', '29', 'Missouri'], ['MT', '30', 'Montana'],
    ['NE', '31', 'Nebraska'], ['NV', '32', 'Nevada'], ['NH', '33', 'New Hampshire'],
    ['NJ', '34', 'New Jersey'], ['NM', '35', 'New Mexico'], ['NY', '36', 'New York'],
    ['NC', '37', 'North Carolina'], ['ND', '38', 'North Dakota'], ['OH', '39', 'Ohio'],
    ['OK', '40', 'Oklahoma'], ['OR', '41', 'Oregon'], ['PA', '42', 'Pennsylvania'],
    ['RI', '44', 'Rhode Island'], ['SC', '45', 'South Carolina'], ['SD', '46', 'South Dakota'],
    ['TN', '47', 'Tennessee'], ['TX', '48', 'Texas'], ['UT', '49', 'Utah'],
    ['VT', '50', 'Vermont'], ['VA', '51', 'Virginia'], ['WA', '53', 'Washington'],
    ['WV', '54', 'West Virginia'], ['WI', '55', 'Wisconsin'], ['WY', '56', 'Wyoming']
  ].freeze

  def change
    create_table :states do |t|
      t.string :code, null: false, limit: 2, index: { unique: true }
      t.string :fips, null: false, limit: 2, index: { unique: true }
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end

    add_check_constraint :states, "code ~ '^[A-Z]{2}$'", name: 'states_code_two_letters'
    add_check_constraint :states, "fips ~ '^[0-9]{2}$'", name: 'states_fips_two_digits'

    reversible { |direction| direction.up { backfill } }
  end

private

  def backfill
    rows = STATES.map { |code, fips, name| { code:, fips:, name: } }
    states = Class.new ActiveRecord::Base do
      self.table_name = 'states'
    end

    states.insert_all rows, record_timestamps: true
  end
end
