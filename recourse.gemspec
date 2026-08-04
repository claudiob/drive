require_relative 'lib/recourse/version'

Gem::Specification.new do |spec|
  spec.name = 'recourse'
  spec.version = Recourse::VERSION
  spec.authors = ['claudiob']
  spec.email = ['claudiob@users.noreply.github.com']

  spec.summary = 'A routes.rb DSL that mounts ready-made resource screens.'
  spec.description = 'Recourse adds a `recourses` method to config/routes.rb. ' \
                     'One line draws the routes, controllers and views needed to ' \
                     'browse a resource, with no files added to the host app. ' \
                     'Any controller or view can be ejected into the app to customize it.'
  spec.homepage = 'https://github.com/claudiob/recourse'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename __FILE__
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .rubocop.yml])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'actionpack', '>= 8.1' # the routing DSL and controllers we extend
  spec.add_dependency 'activerecord', '>= 8.1' # reads the host app's resources
  spec.add_dependency 'pagy', '>= 43.6' # paginates the index pages
  spec.add_dependency 'railties', '>= 8.1' # Rails::Engine and the generators

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
