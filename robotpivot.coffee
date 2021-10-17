# Pivot format: <use x>,<use y>/<angle to rotate>@<center x>,<center y>
# Can specify multiple /...@... rotation actions

pivotDuration =
  90: 500
  180: 600
pivotDelay = 100

timeline = null

parseCoords = (coords) ->
  [x, y] = coords.split ','
  x = parseFloat x
  y = parseFloat y
  if isNaN(x) or isNaN(y)
    console.warn "Invalid coordinates #{coords}"
  {x, y}

animatePivots = (target, pivots, reverse) ->
  pivots = pivots.split /\s+/
  pivots.reverse() if reverse
  transforms = {}
  timeline?.finish()
  timeline = new SVG.Timeline
  for pivot in pivots
    continue unless pivot
    [use, ...rotations] = pivot.split '/'

    use = parseCoords use
    id = "#{use.x},#{use.y}"
    robot = SVG "##{target} use[x='#{use.x}'][y='#{use.y}']"
    unless robot?
      console.warn "Failed to find ##{target} use[x='#{use.x}'][y='#{use.y}']"
      continue
    robot.timeline timeline
    transforms[id] ?= new SVG.Matrix robot.transform()

    rotations.reverse() if reverse
    for rotation in rotations
      [angle, center] = rotation.split '@'
      angle = parseFloat angle
      if isNaN angle
        console.warn "Invalid angle #{angle}"
        continue
      angle = -angle if reverse
      center = parseCoords center
      center = new SVG.Point center
      .transform transforms[id].inverse()
      ## Pivot
      transform =
        rotate: angle
        originX: center.x
        originY: center.y
      robot.animate(pivotDuration[Math.abs angle], pivotDelay, 'after')
      .transform transform, true # relative to previous transformations
      transforms[id] = transforms[id].transform transform

Reveal.on 'fragmentshown', (e) ->
  return unless e.fragment.classList.contains 'robotpivot'
  animatePivots e.fragment.dataset.target, e.fragment.dataset.pivots, false

Reveal.on 'fragmenthidden', (e) ->
  return unless e.fragment.classList.contains 'robotpivot'
  animatePivots e.fragment.dataset.target, e.fragment.dataset.pivots, true
