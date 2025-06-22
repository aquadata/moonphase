#!/usr/bin/env ruby
require_relative 'moonphase'

# Returns the illuminated fraction (0.0–1.0)
def illum_frac(time)
  (1 - Math.cos(moonphase(time))) / 2.0
end

# Returns the illuminated percentage (0.0–100.0), rounded to 1 decimal place
def illum_pct(time)
  (illum_frac(time) * 100).round(1)
end

# Test cases using POSIX timestamps
test_cases = {
  -178070400 => 1.2,
   361411200 => 93.6,
  1704931200 => 0.4,
  2898374400 => 44.2
}

test_cases.each do |ts, expected|
  t = Time.at(ts).utc
  actual = illum_pct(t)
  if actual != expected
    warn "Test failed for #{ts}: got #{actual}, expected #{expected}"
    exit 1
  end
end

puts "All tests passed."