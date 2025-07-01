# frozen_string_literal: true

# Adapted from "moontool.c" by John Walker: See http://www.fourmilab.ch/moontool/
module Moonphase
  extend self

  ECCENT = 0.016718 # Eccentricity of Earth's orbit
  ELONGE = 278.833540 # Ecliptic longitude of the Sun at epoch 1980.0
  ELONGP = 282.596403 # Ecliptic longitude of the Sun at perigee
  TORAD = Math::PI / 180.0

  def fixangle(a)
    ((a % 360) + 360) % 360
  end

  def moonphase(date)
    # Calculation of the Sun's position
    day = (date.to_time.to_i / 86_400 + 2_440_587.5) - 2_444_238.5 # Date within epoch
    m = TORAD * fixangle(((360 / 365.2422) * day) + ELONGE - ELONGP) # Convert from perigee co-ordinates to epoch 1980.0

    # Solve equation of Kepler
    e = m
    delta = e - ECCENT * Math.sin(e) - m
    e -= delta / (1 - ECCENT * Math.cos(e))
    while delta.abs > 1E-6
      delta = e - ECCENT * Math.sin(e) - m
      e -= delta / (1 - ECCENT * Math.cos(e))
    end
    ec = e
    ec = 2 * Math.atan(Math.sqrt((1 + ECCENT) / (1 - ECCENT)) * Math.tan(ec / 2)) #  True anomaly

    lambdasun = fixangle((ec * (180.0 / Math::PI)) + ELONGP) # Sun's geocentric ecliptic longitude
    ml = fixangle(13.1763966 * day + 64.975464) # Moon's mean lonigitude at the epoch
    mm = fixangle(ml - 0.1114041 * day - 349.383063) # 349:  Mean longitude of the perigee at the epoch, Moon's mean anomaly
    ev = 1.2739 * Math.sin(TORAD * (2 * (ml - lambdasun) - mm)) # Evection
    ae = 0.1858 * Math.sin(m) # Annual equation
    mmp = TORAD * (mm + ev - ae - (0.37 * Math.sin(m))) # Corrected anomaly
    lp = ml + ev + (6.2886 * Math.sin(mmp)) - ae + (0.214 * Math.sin(2 * mmp)) # Corrected longitude
    lpp = lp + (0.6583 * Math.sin(TORAD * (2 * (lp - lambdasun)))) # True longitude
    moonage = lpp - lambdasun # Age of the Moon in degrees

    moonage * TORAD
  end

  def illuminated(angle)
    (1 - Math.cos(angle)) / 2
  end
end