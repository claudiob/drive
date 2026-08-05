# Creates the jobs table, and the Postgres type its status column draws from.
class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_enum :job_status, Job::STATUSES

    create_table :jobs do |t|
      t.string :title, null: false
      t.enum :status, enum_type: :job_status, default: :draft, null: false
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
