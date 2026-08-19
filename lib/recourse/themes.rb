# Reopened for the other thing a host says about how every page looks.
module Recourse
  # Colour schemes from code editors a host may draw its pages in. Each names the family
  # its own accents lead with, since a scheme that repaints Bootstrap's blue may not have
  # one, and the families whose 500 step its palette puts dark text on rather than white.
  # Every scheme fills both arms of every ramp, so a page still follows the OS.
  THEMES = {
    dawn: {
      primary: :blue,
      dark_inks: %i[brown cyan gray orange pink purple yellow],
    },
    dracula: {
      primary: :purple,
      dark_inks: %i[blue brown cyan green orange pink purple red yellow],
    },
    gruvbox: {
      primary: :blue,
      dark_inks: %i[cyan gray green yellow],
    },
    monokai: {
      primary: :pink,
      dark_inks: %i[blue brown cyan green orange purple yellow],
    },
    nord: {
      primary: :blue,
      dark_inks: %i[brown cyan green orange pink purple yellow],
    },
    one_dark: {
      primary: :blue,
      dark_inks: %i[blue brown cyan gray green orange pink purple red yellow],
    },
    solarized: {
      primary: :blue,
      dark_inks: %i[blue brown cyan gray green yellow],
    },
    tokyo_night: {
      primary: :blue,
      dark_inks: %i[blue brown cyan gray green orange pink purple red yellow],
    },
  }.freeze

  class << self
    # Which editor scheme the pages are drawn in, or nil for Bootstrap's own palette.
    attr_reader :theme
  end

  # Picks the scheme, and says which eight there are when handed anything else. A name
  # nobody ships would otherwise ask the browser for a stylesheet that is not there and
  # go unnoticed until somebody looked at a page.
  def self.theme=(theme)
    name = theme&.to_sym
    unless name.nil? || THEMES.key?(name)
      raise Error, I18n.t('recourse.unknown_theme', theme:, themes: THEMES.keys.to_sentence)
    end

    @theme = name
  end
end
