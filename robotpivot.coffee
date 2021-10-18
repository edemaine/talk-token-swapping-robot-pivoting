# Pivot format: <use x>,<use y>/<angle to rotate>@<center x>,<center y>
# Can specify multiple /...@... rotation actions

pivotDuration =
  90: 500
  120: 500
  180: 600
pivotDelay = 100
pivotRadius = 0.3

timeline = null

parseCoords = (coords) ->
  [x, y] = coords.split ','
  x = parseFloat x
  y = parseFloat y
  if isNaN(x) or isNaN(y)
    console.warn "Invalid coordinates #{coords}"
  {x, y}

animatePivots = (target, pivots, reverse) ->
  timeline?.finish()
  timeline = new SVG.Timeline
  svg = SVG "##{target} > svg"
  pivotCenter = svg.circle pivotRadius
  .addClass 'pivotCenter'
  .timeline timeline

  pivots = pivots.split /\s+/
  pivots.reverse() if reverse
  transforms = {}
  for pivot in pivots
    continue unless pivot
    [use, ...rotations] = pivot.split '/'

    use = parseCoords use
    robot = SVG "##{target} use[x='#{use.x}'][y='#{use.y}']"
    unless robot?
      console.warn "Failed to find ##{target} use[x='#{use.x}'][y='#{use.y}']"
      continue
    robot.timeline timeline
    id = "#{use.x},#{use.y}"
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
      pivotCenter.animate(0.1, 0, 'after')
      .attr
        cx: center.x
        cy: center.y
      center = new SVG.Point center
      .transform transforms[id].inverse()
      ## Pivot
      transform =
        rotate: angle
        originX: center.x
        originY: center.y
      robot.animate(pivotDuration[Math.abs angle], pivotDelay, 'after')
      .during (t) ->
        unless robot.node.style.filter == "hue-rotate(90deg)"
          robot.node.style.filter = "hue-rotate(#{t * 90}deg)"
      .transform transform, true # relative to previous transformations
      transforms[id] = transforms[id].transform transform

  pivotCenter.animate 0.1, 0, 'last'
  .opacity 0
  .after -> pivotCenter.remove()

Reveal.on 'fragmentshown', (e) ->
  return unless e.fragment.classList.contains 'robotpivot'
  animatePivots e.fragment.dataset.target, e.fragment.dataset.pivots, false

Reveal.on 'fragmenthidden', (e) ->
  return unless e.fragment.classList.contains 'robotpivot'
  animatePivots e.fragment.dataset.target, e.fragment.dataset.pivots, true
