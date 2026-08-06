# A job may name the trade it needs, and may not: the specialty is optional, so the
# column is nullable and the model says `optional: true` to match.
class AddSpecialtyToJobs < ActiveRecord::Migration[8.1]
  def change
    add_reference :jobs, :specialty, foreign_key: true
  end
end
