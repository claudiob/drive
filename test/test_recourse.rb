require 'test_helper'

# How the gem presents itself to a host application.
class TestRecourse < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Recourse::VERSION
  end

  def test_the_engine_is_registered_with_the_host_app
    railtie_classes = Rails.application.railties.map(&:class)

    assert_includes railtie_classes, Recourse::Engine
  end
end
