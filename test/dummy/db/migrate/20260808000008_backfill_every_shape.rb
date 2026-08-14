# Backfills two rows for every model with anything optional about it: one carrying
# every value it can carry, and one carrying only what it must. A table then shows
# each column both ways — filled and blank — which is what these pages are for.
# Models rather than SQL, since half of these columns are encrypted and only the
# model holds the key. Geography is left alone: states, counties and ZIPs are real
# data, and this adds nothing to them.
class BackfillEveryShape < ActiveRecord::Migration[8.1]
  def change
    reversible { |direction| direction.up { backfill } }
  end

private

  def backfill
    referenced
    franchises
    providers
    contacts
    bookings
    settings
    locations
  end

  # The rows the two shapes below point at, and the models with nothing optional to
  # tell apart: one row says as much about them as two would.
  def referenced
    Source.find_or_create_by! name: 'Backfill'
    Agent.find_or_create_by! email: 'backfill@example.com'
    %w[Roofing Plumbing].each { |name| Specialty.find_or_create_by! name: }
    App.find_or_create_by! name: 'Everything App' do |app|
      app.webhook_url = 'https://example.com/hooks/everything'
      app.agent = agent
    end
    App.find_or_create_by! name: 'Bare App'
  end

  def franchises
    Franchise.find_or_create_by! name: 'Everything Franchise' do |franchise|
      franchise.assign_attributes key: 'k-1701', lead_status: 'signed',
                                  lead_source: 'Referral', multiple: false
    end
    Franchise.find_or_create_by! name: 'Bare Franchise'
  end

  def providers
    Provider.find_or_create_by! phone: '2125550100' do |one|
      one.assign_attributes everything_provider
    end
    # An email even on the bare row: today's model requires one, and the remake
    # migration right after this rewrites every provider's address anyway.
    Provider.find_or_create_by! phone: '2125550101' do |provider|
      provider.assign_attributes name: 'Bare Provider', time_zone: 'Pacific Time (US & Canada)',
                                 email: 'bare-provider@example.com'
    end
  end

  def everything_provider
    {
      name: 'Everything Provider', email: 'provider@example.com', pin: '824193',
      time_zone: 'Eastern Time (US & Canada)', hourly_rate: 95, minimum_price: 250,
      review_rating: 4.75, review_number: 128, signed_on: Date.new(2026, 3, 14),
      signed_by: 'Ada Lovelace', team_size: :small, active: false, insured: false,
      paused_until: Time.zone.local(2026, 12, 24), subscribed: false,
      franchise: Franchise.find_by!(name: 'Everything Franchise'),
    }
  end

  def contacts
    Contact.find_or_create_by! phone: '2125550110' do |contact|
      contact.assign_attributes name: 'Everything', surname: 'Contact', agent:,
                                email: 'everything@example.com', source: source,
                                app: App.find_by!(name: 'Everything App')
    end
    Contact.find_or_create_by! phone: '2125550111'
  end

  def bookings
    Booking.find_or_create_by! summary: 'Everything booking' do |one|
      one.assign_attributes everything_booking
    end
    Booking.find_or_create_by! summary: 'Bare booking' do |booking|
      booking.assign_attributes contact: Contact.find_by!(phone: '2125550111'), zip: ZIP.first!
    end
  end

  def everything_booking
    {
      contact: Contact.find_by!(phone: '2125550110'), zip: ZIP.first!, quote_count: 3,
      comment: 'Every optional column of a booking, filled.', query: 'leaking roof',
      timeline: 'this week', city: 'Cupertino', street: '1 Infinite Loop', satisfied: true,
      media_urls: %w[https://example.com/roof.jpg], subscribed: false, status: :scheduled,
      nominated_at: Time.zone.local(2026, 8, 1, 9, 30), notified_at: Time.zone.local(2026, 8, 1, 9),
      app: App.find_by!(name: 'Everything App'), specialty: Specialty.find_by!(name: 'Roofing'),
      provider: Provider.find_by!(name: 'Everything Provider'),
    }
  end

  def settings
    Setting.find_or_create_by! key: 'everything.setting' do |setting|
      setting.assign_attributes value: 'Rome', kind: :text, agent:
    end
    Setting.find_or_create_by!(key: 'bare.setting') { |setting| setting.value = '42' }
  end

  def locations
    Location.find_or_create_by! city: 'Everything City' do |location|
      location.assign_attributes zip: ZIP.first!, street: '2 Infinite Loop', source:, agent:
    end
    Location.find_or_create_by!(city: 'Bare City') { |location| location.zip = ZIP.first! }
  end

  def agent = Agent.find_by!(email: 'backfill@example.com')

  def source = Source.find_by!(name: 'Backfill')
end
