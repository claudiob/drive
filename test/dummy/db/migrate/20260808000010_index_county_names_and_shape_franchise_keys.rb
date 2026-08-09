# Counties are searched by name as well as by FIPS, and a search reads the columns an
# index covers. The name is not unique — more than twenty states have a Washington.
class IndexCountyNamesAndShapeFranchiseKeys < ActiveRecord::Migration[8.1]
  def change
    add_index :counties, :name
  end
end
