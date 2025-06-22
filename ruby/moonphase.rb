# frozen_string_literal: true

# Adapted from "moontool.c" by John Walker: See http://www.fourmilab.ch/moontool/
module Moonphase
  # Calculates the moon's age in radians for a given date.
  #
  # @param date [Time] The date for which to calculate the moon phase.
  # @return [Float] The moon's age in radians.
  def self.moonphase(date)
    ud = date.to_i # Unix timestamp (seconds since epoch)
    eccent = 0.016718 # Eccentricity of Earth's orbit
    elonge = 278.833540 # Ecliptic longitude of the Sun at epoch 1980.0
    elongp = 282.596403 # Ecliptic longitude of the Sun at perigee
    torad = Math::PI / 180.0

    # Helper lambda to fix angle to be within 0-360
    fixangle = lambda do |a|
      # In Ruby, a % n can be negative if a is negative.
      # ((a % 360) + 360) % 360 ensures a positive result.
      ((a % 360) + 360) % 360
    end

    # Calculation of the Sun's position
    day = (ud / 86400.0 + 2440587.5) - 2444238.5 # Date within epoch

    # Convert from perigee co-ordinates to epoch 1980.0
    m = torad * fixangle.call(((360 / 365.2422) * day) + elonge - elongp)

    # Solve equation of Kepler
    e = m
    delta = e - eccent * Math.sin(e) - m
    e -= delta / (1 - eccent * Math.cos(e))
    while delta.abs > 1E-6
      delta = e - eccent * Math.sin(e) - m
      e -= delta / (1 - eccent * Math.cos(e))
    end
    ec = e

    # True anomaly
    ec = 2 * Math.atan(Math.sqrt((1 + eccent) / (1 - eccent)) * Math.tan(ec / 2.0))

    # Sun's geocentric ecliptic longitude
    lambdasun = fixangle.call((ec * (180.0 / Math::PI)) + elongp)

    # Moon's mean lonigitude at the epoch
    ml = fixangle.call(13.1763966 * day + 64.975464)

    # 349: Mean longitude of the perigee at the epoch, Moon's mean anomaly
    mm = fixangle.call(ml - 0.1114041 * day - 349.383063)

    # Evection
    ev = 1.2739 * Math.sin(torad * (2 * (ml - lambdasun) - mm))

    # Annual equation
    ae = 0.1858 * Math.sin(m)

    # Corrected anomaly
    mmp = torad * (mm + ev - ae - (0.37 * Math.sin(m)))

    # Corrected longitude
    lp = ml + ev + (6.2886 * Math.sin(mmp)) - ae + (0.214 * Math.sin(2 * mmp))

    # True longitude
    lpp = lp + (0.6583 * Math.sin(torad * (2 * (lp - lambdasun))))

    # Age of the Moon in degrees
    moonage_degrees = lpp - lambdasun

    moonage_degrees * torad
  end
end
