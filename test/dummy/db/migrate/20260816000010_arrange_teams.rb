class ArrangeTeams < ActiveRecord::Migration[8.1]
  # A flat list somebody puts in order by hand, which is the plainest thing an
  # arranged table can be: nothing nests teams, so the whole table is the one scope
  # and a position means the same thing wherever the page is reached from.
  #
  # Indexed because `recourse_order` refuses to arrange by a column no table can be
  # read in the order of — this is the column that proves the check passes, and
  # `uid` beside it, indexed by nothing, is the one that proves it fails.
  def change
    add_column :teams, :position, :integer, null: false, default: 0
    add_index :teams, :position

    up_only { connection.execute 'update teams set position = id' }
  end
end
