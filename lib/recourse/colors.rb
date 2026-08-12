# Reopened for the one thing a host says about how every page looks.
module Recourse
  # Colour families a host may call primary. Five of the sixteen Bootstrap ships:
  # each is dark enough at its 500 step to carry white text, which is what
  # `--bs-primary-contrast` assumes and what the others would quietly break.
  COLORS = %i[blue orange purple pink brown].freeze

  class << self
    # Which family the pages call primary, or nil for Bootstrap's own blue.
    attr_reader :color
  end

  # Picks the primary colour, and says which five there are when handed anything
  # else. A typo would otherwise write `var(--bs-purpel-500)` into every page and go
  # unnoticed until somebody looked at a button.
  def self.color=(color)
    name = color&.to_sym
    unless name.nil? || COLORS.include?(name)
      raise Error, I18n.t('recourse.unknown_color', color:, colors: COLORS.to_sentence)
    end

    @color = name
  end
end
