# frozen_string_literal: true

require_relative 'moonphase'
require 'time' # Required for Time.gm

# Helper proc to calculate illuminated fraction and round it
ilf = lambda do |time_obj|
  moon_age_rad = Moonphase.moonphase(time_obj)
  illuminated_fraction = (1 - Math.cos(moon_age_rad)) / 2.0
  (illuminated_fraction * 100).round(1)
end

# Test cases comparable to the Python script
# Timestamps are seconds since epoch, UTC
tests = {
  -178070400 => 1.2,
  361411200 => 93.6,
  1704931200 => 0.4,
  2898374400 => 44.2
}

puts "Running tests for moonphase.rb..."
all_passed = true

tests.each do |timestamp, expected_fraction|
  time_obj = Time.gm(1970, 1, 1) + timestamp # Create Time object from UTC timestamp
  calculated_fraction = ilf.call(time_obj)
  if calculated_fraction == expected_fraction
    puts "PASSED: Timestamp #{timestamp}, Expected: #{expected_fraction}, Got: #{calculated_fraction}"
  else
    puts "FAILED: Timestamp #{timestamp}, Expected: #{expected_fraction}, Got: #{calculated_fraction}"
    all_passed = false
  end
end

if all_passed
  puts "All tests passed!"
else
  puts "Some tests failed."
  exit 1 # Indicate failure
end

puts "\nExample usage:"
# Show how to get illuminated fraction and percent using the new Ruby code
# Example date: 2023-10-26 12:00:00 UTC (New Moon was around 2023-10-14)
example_time_utc = Time.gm(2023, 10, 26, 12, 0, 0)
moon_age_rad_example = Moonphase.moonphase(example_time_utc)

illuminated_fraction_example = (1 - Math.cos(moon_age_rad_example)) / 2.0
illuminated_percent_example = (illuminated_fraction_example * 100).round(1)

puts "For date: #{example_time_utc.strftime('%Y-%m-%d %H:%M:%S UTC')}"
puts "Moon age in radians: #{moon_age_rad_example.round(4)}"
puts "Illuminated fraction: #{illuminated_fraction_example.round(4)}"
puts "Illuminated percent: #{illuminated_percent_example}%"

# Another example: Full Moon (approximately)
# Full Moon was around 2023-10-28
example_time_full_moon_utc = Time.gm(2023, 10, 28, 20, 0, 0) # Approximate time of Full Moon
moon_age_rad_full = Moonphase.moonphase(example_time_full_moon_utc)
illuminated_fraction_full = (1 - Math.cos(moon_age_rad_full)) / 2.0
illuminated_percent_full = (illuminated_fraction_full * 100).round(1)

puts "\nFor date (approx. Full Moon): #{example_time_full_moon_utc.strftime('%Y-%m-%d %H:%M:%S UTC')}"
puts "Moon age in radians: #{moon_age_rad_full.round(4)}" # Should be close to PI for Full Moon
puts "Illuminated fraction: #{illuminated_fraction_full.round(4)}" # Should be close to 1.0
puts "Illuminated percent: #{illuminated_percent_full}%" # Should be close to 100.0
