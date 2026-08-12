# Two types this app has and Active Record does not: money and a share of it. A
# `decimal` column says how many digits it keeps and nothing about what they mean, so
# a page cannot tell `hourly_rate` from `commission_rate` — and it is the app, not the
# gem, that knows which is which.
#
# Registered with a block, so `Price` is autoloaded when a model first asks for the
# type rather than during boot.
ActiveSupport.on_load :active_record do
  ActiveRecord::Type.register(:price) { |_name, **options| Price.new(**options) }
  ActiveRecord::Type.register(:percentage) { |_name, **options| Percentage.new(**options) }
end

# The migration side of the same two words: `t.price :hourly_rate` writes the decimal
# `Price` reads back. Rails keeps `define_column_methods` private, so a column method
# is written out and delegates to the one it is a kind of.
module MoneyColumns
  # A column holding money, in the one shape this app keeps it in.
  def price(*names, **options)
    names.each { |name| decimal name, precision: Price::PRECISION, scale: Price::SCALE, **options }
  end

  # A column holding a share of something, in the one shape this app keeps those in.
  def percentage(*names, **options)
    names.each do |name|
      decimal name, precision: Percentage::PRECISION, scale: Percentage::SCALE, **options
    end
  end
end

ActiveRecord::ConnectionAdapters::TableDefinition.include MoneyColumns
