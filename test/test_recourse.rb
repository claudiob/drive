require 'test_helper'

class TestRecourse < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Recourse::VERSION
  end
end
