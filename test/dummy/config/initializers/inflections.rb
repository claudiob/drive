ActiveSupport::Inflector.inflections :en do |inflect|
  # Every acronym this app names, and no others: an app registers what it says. The
  # gem it mounts registers nothing, the way it sets no time zone and no logger.
  inflect.acronym 'API'
  inflect.acronym 'CRM'
  inflect.acronym 'OpenAI'
  inflect.acronym 'PIN'
  # Singulars only: the gem pluralizes a model's own human name, so `ZIPs` reads
  # right on a page without `zips` camelizing to `ZIPs` for Rails.
  inflect.acronym 'URL'
  inflect.acronym 'ZIP'
end
