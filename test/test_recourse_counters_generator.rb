require 'test_helper'
require 'rails/generators/test_case'

Rails.application.load_generators
require 'generators/recourse/counters/counters_generator'

class TestRecourseCountersGenerator < Rails::Generators::TestCase
  tests Recourse::Generators::CountersGenerator
  destination File.expand_path('../tmp/counted', __dir__)

  def setup
    prepare_destination
    write 'app/models/job.rb', "class Job < ApplicationRecord\n  belongs_to :location\nend\n"
    write 'app/models/location.rb', "class Location < ApplicationRecord\nend\n"
  end

  # `rails generate recourse:counters` has to reach it by that name, which is the
  # file's path and the class's namespace agreeing rather than anything declared.
  def test_it_answers_to_the_name_typed_in_a_terminal
    assert_equal Recourse::Generators::CountersGenerator,
                 Rails::Generators.find_by_namespace('recourse:counters')
  end

  # The three pieces of jobs-count-on-locations: the backfilled column, the option
  # that keeps it filled, and the has_many that reads it back — plus, on the same
  # job file, the far side of the optional messages key, kept rather than destroyed.
  # Run twice, because idempotence is the point: everything is already there the
  # second time, so no second migration and no repeated line in a model.
  def test_it_writes_whichever_piece_of_a_count_is_missing_and_writes_it_once
    2.times { run_generator }

    assert_migration 'db/migrate/add_jobs_count_to_locations.rb',
                     /add_column :locations, :jobs_count, :integer, default: 0, null: false/
    assert_migration 'db/migrate/add_jobs_count_to_locations.rb', /update locations set jobs_count/
    assert_equal 1, Dir.glob("#{destination_root}/db/migrate/*_add_jobs_count_to_locations.rb").size
    assert_file 'app/models/job.rb' do |job|
      assert_equal 1, job.scan('belongs_to :location, counter_cache: true, touch: true').count
      assert_equal 1, job.scan('has_many :messages, dependent: :nullify').count
    end
    assert_file 'app/models/location.rb', /has_many :jobs, dependent: :destroy/
  end

  # Reading the USAGE is what `--help` does, and it has to say what comes after
  # the run: the migrations wait for `db:migrate`.
  def test_it_has_a_usage_to_print
    assert_match 'db:migrate', Recourse::Generators::CountersGenerator.desc
  end

private

  def write(path, content)
    file = File.join destination_root, path
    FileUtils.mkdir_p File.dirname(file)
    File.write file, content
  end
end
