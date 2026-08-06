# Enough demo data for the native screens to have something to show: contacts spread
# across the alphabet, homes at claimed and unclaimed locations, and a conversation
# apiece so the Messages tab has rows and unread ones among them.

PEOPLE = [
  'Ada Lovelace', 'Aaron Bujak', 'Aaron Dao', 'Able Nguyen', 'Adam Ortiz',
  'Bianca Rossi', 'Bruno Marchetti', 'Carla Espinoza', 'Dario Conti',
  'Elena Ricci', 'Fabio Greco', 'Grace Hopper', 'Hugo Bernard', 'Irene Fontana',
  'Jonas Weber', 'Klara Novak', 'Luca Moretti', 'Marta Silva', 'Nadia Haddad',
  'Omar Farouk', 'Paolo Bianchi', 'Quinn Doyle', 'Rosa Delgado', 'Sofia Ivanova',
  'Tomas Nowak', 'Ursula Klein', 'Viktor Petrov', 'Wanda Kowalski',
  'Xavier Dubois', 'Yara Haddad', 'Zoe Papadopoulos',
]

['ada@example.com', 'grace@example.com'].each { |email| Agent.find_or_create_by! email: }

# By id, because the signed-in agent is stood in for with the first one — claiming has
# to reach whoever the Lists screen is going to ask about.
agents = Agent.order(:id).first 2

# Four locations, the first two claimed, so the Lists screen has both kinds to count.
locations = ZIP.order(:code).limit(4).each_with_index.map do |zip, index|
  # Found by its ZIP alone: `street` is encrypted non-deterministically, so a
  # `find_or_create_by` on it matches nothing ever and quietly creates a row a run.
  location = Location.find_or_create_by! zip: do |record|
    record.street = "#{100 + index} Main Street"
    record.city = zip.city
  end

  location.update! agent: agents[index]
  location
end

# "My Card": the agent looking at the app is a contact too, found by the email the two
# share — which is what deterministic encryption on `email` buys.
Contact.find_or_create_by! phone: '5552999998' do |contact|
  contact.name = agents.first.name
  contact.email = agents.first.email
end

PEOPLE.each_with_index do |person, index|
  name, surname = person.split

  contact = Contact.find_or_create_by! phone: format('5552%06d', index) do |record|
    record.name = name
    record.surname = surname
    record.email = "#{name.downcase}@example.com"
  end

  # Every third contact has no home at all, so "Unclaimed" is not merely the
  # contacts at an unclaimed location.
  next if (index % 3).zero?

  Home.find_or_create_by! contact:, location: locations[index % locations.size]
end

# A contact with no name, to prove the '#' section and the phone fallback.
Contact.find_or_create_by! phone: '5552999999'

JOBS = [
  'Replace the water heater', 'Repaint the porch', 'Regrade the driveway',
  'Service the furnace', 'Reseal the deck', 'Replace the garage door',
  'Clear the gutters', 'Rewire the basement',
]

# Spread across the locations, so some belong to a claimed one and some do not — and
# `needing_attention` splits them again by id, which is the placeholder rule.
JOBS.each_with_index do |title, index|
  Job.find_or_create_by! title:, location: locations[index % locations.size]
end

Contact.order(:id).limit(12).each_with_index do |contact, index|
  Message.find_or_create_by! contact:, content: "Hi, it's #{contact.name || 'me'}." do |message|
    message.inbound = true
    # Every other conversation stays unread, so the dot and the smart list show.
    message.read_at = Time.current if index.even?
  end

  # A reply from the agent, so a thread has both sides to draw.
  said = 'Thanks — I will take a look today.'
  reply = Message.find_or_create_by! contact:, content: said do |message|
    message.inbound = false
  end

  # Set outside the block, which only runs on create: every other reply is delivered,
  # so the tick shows in both of its states however often this is run.
  reply.update! delivered_at: index.even? ? Time.current : nil
end
