require "minitest/autorun"
require "date"
require_relative "moonphase"

class TestMoonphase < Minitest::Test
  def test_moonphase
    date = Date.new(2024, 7, 1)
    angle = Moonphase.moonphase(date)
    illuminated_fraction = Moonphase.illuminated(angle)
    illuminated_percent = illuminated_fraction * 100

    assert_in_delta(0.278, illuminated_fraction, 0.01)
    assert_in_delta(27.8, illuminated_percent, 1)
  end
end