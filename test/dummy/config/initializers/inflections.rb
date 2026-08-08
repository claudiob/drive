ActiveSupport::Inflector.inflections :en do |inflect|
  # Every acronym this app names, and no others: an app registers what it says. The
  # gem it mounts registers nothing, the way it sets no time zone and no logger.
  inflect.acronym 'API'
  inflect.acronym 'CRM'
  inflect.acronym 'OpenAI'
  inflect.acronym 'PIN'
  # The plural of each is registered too, or `media_urls` heads a column
  # 'Media urls' and `zips` humanizes to 'Zips'.
  inflect.acronym 'URL'
  inflect.acronym 'URLs'
  inflect.acronym 'ZIP'
  inflect.acronym 'ZIPs'
end
