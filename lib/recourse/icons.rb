module Recourse
  # Bootstrap Icons name for a resource title, keyed by the title as it displays.
  NAVIGATION_ICONS = {
    'Agents' => 'robot', 'Answers' => 'question-circle', 'Apps' => 'window',
    'Assessments' => 'clipboard-check', 'Bookings' => 'calendar-check',
    'Brands' => 'buildings', 'Campaigns' => 'megaphone', 'Contacts' => 'person-rolodex',
    'Contract' => 'file-earmark-check', 'Conversations' => 'chat-dots', 'Counties' => 'map',
    'CRM' => 'plugin', 'Echoes' => 'soundwave', 'Episodes' => 'collection-play',
    'Evaluations' => 'speedometer2', 'Franchises' => 'shop', 'Home' => 'house',
    'Logout' => 'box-arrow-right', 'Markets' => 'pin-map', 'Offer questions' => 'gift',
    'Optimizations' => 'sliders', 'Platforms' => 'plugin', 'Profile' => 'person-circle',
    'Prompts' => 'terminal', 'Providers' => 'briefcase',
    'Satisfaction questions' => 'emoji-smile', 'Searches' => 'search', 'Settings' => 'gear',
    'Sources' => 'signpost', 'Specialties' => 'award', 'Specialty matches' => 'award',
    'States' => 'geo', 'Verticals' => 'bar-chart', 'ZIPs' => 'geo-alt-fill',
  }.freeze

  # Shown when a resource is not in the map, so a list of links stays aligned.
  FALLBACK_ICON = 'circle'
end
