module Recourse
  # Bootstrap Icons name for a resource title, keyed by the title as it displays.
  NAVIGATION_ICONS = {
    'Agents' => 'robot', 'Answers' => 'question-circle', 'Apps' => 'window',
    'Assessments' => 'clipboard-check', 'Bookings' => 'calendar-check',
    'Brands' => 'buildings', 'Campaigns' => 'megaphone', 'Contacts' => 'person-rolodex',
    'Contract' => 'file-earmark-check', 'Conversations' => 'chat-dots', 'Counties' => 'map',
    'CRM' => 'plugin', 'Echoes' => 'soundwave', 'Episodes' => 'collection-play',
    'Evaluations' => 'speedometer2', 'Franchises' => 'shop', 'Home' => 'house',
    'Locations' => 'geo-alt', 'Logout' => 'box-arrow-right', 'Markets' => 'pin-map',
    'Offer questions' => 'gift',
    'Optimizations' => 'sliders', 'Platforms' => 'plugin', 'Profile' => 'person-circle',
    'Prompts' => 'terminal', 'Providers' => 'briefcase',
    'Satisfaction questions' => 'emoji-smile', 'Searches' => 'search', 'Settings' => 'gear',
    'Sources' => 'signpost', 'Specialties' => 'award', 'Specialty matches' => 'award',
    'States' => 'geo', 'Verticals' => 'bar-chart', 'ZIPs' => 'geo-alt-fill',
  }.freeze

  # Shown when a resource is not in the map, so a list of links stays aligned.
  FALLBACK_ICON = 'circle'

  # The same titles again as SF Symbols, for a native tab bar. Deliberately plain
  # symbols that have shipped for years: a name iOS does not know draws nothing.
  NATIVE_ICONS = {
    'Agents' => 'person.text.rectangle', 'Answers' => 'questionmark.circle',
    'Apps' => 'macwindow', 'Assessments' => 'checklist', 'Bookings' => 'calendar',
    'Brands' => 'building.2', 'Campaigns' => 'megaphone', 'Contacts' => 'person.2',
    'Contract' => 'doc.text', 'Conversations' => 'bubble.left.and.bubble.right',
    'Counties' => 'map', 'CRM' => 'puzzlepiece', 'Echoes' => 'waveform',
    'Episodes' => 'play.rectangle', 'Evaluations' => 'speedometer', 'Franchises' => 'bag',
    'Home' => 'house', 'Locations' => 'mappin.and.ellipse', 'Logout' => 'arrow.right.square',
    'Markets' => 'mappin.circle', 'Offer questions' => 'gift',
    'Optimizations' => 'slider.horizontal.3', 'Platforms' => 'puzzlepiece',
    'Profile' => 'person.crop.circle', 'Prompts' => 'terminal', 'Providers' => 'briefcase',
    'Satisfaction questions' => 'face.smiling', 'Searches' => 'magnifyingglass',
    'Settings' => 'gearshape', 'Sources' => 'signpost.right', 'Specialties' => 'rosette',
    'Specialty matches' => 'rosette', 'States' => 'globe', 'Verticals' => 'chart.bar',
    'ZIPs' => 'mappin',
  }.freeze

  # Shown for a title the native map does not name, so a tab still has an icon.
  FALLBACK_NATIVE_ICON = 'circle'
end
