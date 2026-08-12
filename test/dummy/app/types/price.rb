# Money, which is a decimal that means something: this app keeps eight figures of it
# and two decimal places, and says so once here rather than at every column.
class Price < ActiveRecord::Type::Decimal
  PRECISION = 10
  SCALE = 2

  def initialize(precision: PRECISION, scale: SCALE, **)
    super
  end

  # What `type_for_attribute` answers, which is what a page formats by.
  def type = :price
end
