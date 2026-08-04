require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create

require 'rubocop/rake_task'

RuboCop::RakeTask.new

# Ceiling for every code file, blank and comment lines included.
MAX_FILE_LINES = 100

# Prose and markup are exempt: docs, the license, and views of any length.
EXEMPT_EXTENSIONS = %w[.erb .html .md .txt].freeze

# Migrations are exempt too: a backfill is as long as the data it carries.
MIGRATIONS = 'db/migrate/'

desc "Fail if any code file is longer than #{MAX_FILE_LINES} lines"
task :file_length do
  files = `git ls-files -z`.split "\x0"
  code = files.reject do |file|
    EXEMPT_EXTENSIONS.include?(File.extname(file)) || file.include?(MIGRATIONS)
  end
  too_long = code.select { |file| File.readlines(file).size > MAX_FILE_LINES }

  abort "Longer than #{MAX_FILE_LINES} lines: #{too_long.join ', '}" if too_long.any?
end

task default: %i[test rubocop file_length]
