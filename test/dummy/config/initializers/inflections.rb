ActiveSupport::Inflector.inflections :en do |inflect|
  # Every acronym this app names, and no others: an app registers what it says. The
  # gem it mounts registers nothing, the way it sets no time zone and no logger.
  inflect.acronym 'FIPS'
  # Singulars only: the gem pluralizes a model's own human name, so `MSAs` reads
  # right on a page without `msas` camelizing to `MSAs` for Rails — which would
  # rename the controller Rails computes from the path.
  inflect.acronym 'MSA'
  inflect.acronym 'URL'
end
