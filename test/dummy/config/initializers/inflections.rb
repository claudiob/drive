ActiveSupport::Inflector.inflections :en do |inflect|
  # The plural is registered too, or `zips` humanizes to 'Zips' in every heading.
  inflect.acronym 'ZIP'
  inflect.acronym 'ZIPs'
end
