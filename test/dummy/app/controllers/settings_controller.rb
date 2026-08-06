# The Settings tab, shaped like iOS Settings: an account row, then grouped cards of
# rows with a coloured icon apiece.
class SettingsController < ApplicationController
  # Icon and tint per row, as SF Symbol names — the native screen draws them, so this
  # is not the Bootstrap Icons map the console uses.
  ROWS = [
    [
      { title: 'Appearance', symbol: 'circle.lefthalf.filled', tint: 'gray', detail: 'Automatic' },
      { title: 'Sort Order', symbol: 'arrow.up.arrow.down', tint: 'blue', detail: 'First Name' },
      { title: 'Notifications', symbol: 'bell.badge.fill', tint: 'red', detail: 'On' },
    ],
    [
      { title: 'Markets', symbol: 'map.fill', tint: 'green' },
      { title: 'Sources', symbol: 'signpost.right.fill', tint: 'orange' },
      { title: 'Agents', symbol: 'person.2.fill', tint: 'indigo' },
    ],
  ]

  # Names the agent looking at it, then the groups.
  def show
    render json: { account: account, groups: groups }
  end

private

  def account
    return unless Current.agent

    { name: Current.agent.name, detail: Current.agent.email, initials: initials }
  end

  def initials
    Current.agent.name.to_s.split.map(&:first).join.upcase.presence || '?'
  end

  def groups
    ROWS.map { |rows| { rows: rows } }
  end
end
