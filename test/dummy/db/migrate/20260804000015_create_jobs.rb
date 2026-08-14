# Creates the jobs table; a check constraint keeps the status column to the
# words the model admits, which any database can enforce.
class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :jobs do |t|
      t.string :title, null: false
      t.string :status, default: :draft, null: false
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end

    add_check_constraint :jobs, "status IN (#{quoted Job::STATUSES})", name: 'jobs_status_known'
  end

private

  # The words the column admits, quoted for the constraint that rejects the rest.
  def quoted(words)
    words.map { |word| "'#{word}'" }.join ', '
  end
end
