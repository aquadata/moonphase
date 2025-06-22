#!/usr/bin/env ruby
# Adapted from "moontool.c" by John Walker: http://www.fourmilab.ch/moontool/
# Returns the age of the moon in radians for the given Time object
def moonphase(time)
  ud = time.to_i
  eccent = 0.016718 # Eccentricity of Earth's orbit
  elonge = 278.833540 # Ecliptic longitude of the Sun at epoch 1980.0
  elongp = 282.596403 # Ecliptic longitude of the Sun at perigee
  torad = Math::PI / 180.0
  fixangle = ->(a) { ((a % 360) + 360) % 360 }

  # Calculation of the Sun's position
  day = (ud / 86400.0 + 2440587.5) - 2444238.5
  m = torad * fixangle.call((360.0 / 365.2422) * day + elonge - elongp)

  # Solve Kepler's equation
  e = m
  delta = e - eccent * Math.sin(e) - m
  e -= delta / (1 - eccent * Math.cos(e))
  while delta.abs > 1e-6
    delta = e - eccent * Math.sin(e) - m
    e -= delta / (1 - eccent * Math.cos(e))
  end
  ec = 2 * Math.atan(Math.sqrt((1 + eccent) / (1 - eccent)) * Math.tan(e / 2))

  lambdasun = fixangle.call(ec * (180.0 / Math::PI) + elongp)
  ml = fixangle.call(13.1763966 * day + 64.975464)
  mm = fixangle.call(ml - 0.1114041 * day - 349.383063)
  ev = 1.2739 * Math.sin(torad * (2 * (ml - lambdasun) - mm))
  ae = 0.1858 * Math.sin(m)
  mmp = torad * (mm + ev - ae - 0.37 * Math.sin(m))
  lp = ml + ev + 6.2886 * Math.sin(mmp) - ae + 0.214 * Math.sin(2 * mmp)
  lpp = lp + 0.6583 * Math.sin(torad * (2 * (lp - lambdasun)))
  moonage = lpp - lambdasun

  fixangle.call(moonage) * torad
end