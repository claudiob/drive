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
  location = Location.find_or_create_by! zip:, street: "#{100 + index} Main Street" do |record|
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

Job.find_or_create_by! title: 'Replace the water heater', location: locations.first
Job.find_or_create_by! title: 'Repaint the porch', location: locations.second

Contact.order(:id).limit(12).each_with_index do |contact, index|
  Message.find_or_create_by! contact:, content: "Hi, it's #{contact.name || 'me'}." do |message|
    message.inbound = true
    # Every other conversation stays unread, so the dot and the smart list show.
    message.read_at = Time.current if index.even?
  end
end
