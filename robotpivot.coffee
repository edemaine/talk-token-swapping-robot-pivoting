# Pivot format: <use x>,<use y>/<angle to rotate>@<center x>,<center y>
# Can specify multiple /...@... rotation actions

pivotDuration =
  60: 300
  90: 500
  120: 500
  180: 600
pivotDelay = 100
pivotFade = 100
pivotRadius = 0.15

timeline = null

parseXY = (coords) ->
  [x, y] = coords.split ','
  x = parseFloat x
  y = parseFloat y
  if isNaN(x) or isNaN(y)
    console.warn "Invalid coordinates #{coords}"
  {x, y}

hexCorners =
  C: {x: hexX/2, y: hexY}  # negative of first two entries of hexagon viewBox
  # All remaining corners are relative to the center above:
  R: {x: 0.5, y: 0}
  BR: {x: 0.25, y: hexY}
  BL: {x: -0.25, y: hexY}
  L: {x: -0.5, y: 0}
  TL: {x: -0.25, y: -hexY}
  TR: {x: 0.25, y: -hexY}

animatePivots = (target, pivots, reverse) ->
  timeline?.finish()
  timeline = new SVG.Timeline
  root = document.getElementById target
  unless root?
    return console.warn "Invalid target #{target}"
  svg = SVG "##{target} > svg"
  pivotCenter = svg.circle 2*pivotRadius
  .addClass 'pivotCenter'
  .opacity 0
  .timeline timeline
  if root.classList.contains 'hexrobots'
    parseCoords = (coords) ->
      if (match = /^(T|B)?(L|R)|C/.exec coords)?
        {x, y} = hexCorners[match[0]]
        coords = coords[match[0].length..]
        x += hexCorners.C.x
        y += hexCorners.C.y
      else
        x = y = 0
      parsed = parseXY coords
      x += parsed.x * hexX
      y += parsed.y * hexY
      {x, y}
    select = (x) ->
      s = (Math.trunc(100*x)/100).toFixed 2
      if s.endsWith '0'
        s = s[...-1] while s.endsWith '0'
        s = s[...-1] if s.endsWith '.'
        "='#{s}'"
      else
        "^='#{s}'"
  else
    parseCoords = parseXY
    select = (x) -> "='#{x.toFixed 0}'"

  pivots = pivots.split /\s+/
  pivots.reverse() if reverse
  transforms = {}
  for pivot in pivots
    continue unless pivot
    [use, ...rotations] = pivot.split '/'

    use = parseCoords use
    selector = "##{target} use[x#{select use.x}][y#{select use.y}]"
    robot = SVG selector
    unless robot?
      console.warn "Failed to select #{selector}"
      continue
    robot.timeline timeline
    id = "#{use.x},#{use.y}"
    transforms[id] ?= new SVG.Matrix robot.transform()

    rotations.reverse() if reverse
    rotations = (rotation.split '@' for rotation in rotations)
    for [angle, centerString], i in rotations
      angle = parseFloat angle
      if isNaN angle
        console.warn "Invalid angle #{angle}"
        continue
      angle = -angle if reverse
      center = parseCoords centerString
      unless i > 0 and rotations[i-1][1] == centerString
        pivotCenter.animate 0.1, 0, 'after'
        .attr
          cx: center.x
          cy: center.y
        pivotCenter.animate pivotFade, 0, 'after'
        .opacity 1
      center = new SVG.Point center
      .transform transforms[id].inverse()
      ## Pivot
      transform =
        rotate: angle
        originX: center.x
        originY: center.y
      robot.animate(pivotDuration[Math.abs angle], pivotDelay, 'after')
      .during do (robot) -> (t) ->
        unless robot.node.style.filter == "hue-rotate(90deg)"
          robot.node.style.filter = "hue-rotate(#{t * 90}deg)"
      .transform transform, true # relative to previous transformations
      transforms[id] = transforms[id].transform transform
      unless i < rotations.length-1 and rotations[i+1][1] == centerString
        pivotCenter.animate pivotFade, 0, 'after'
        .opacity 0

  pivotCenter.animate 0.1, 0, 'last'
  .after -> pivotCenter.remove()

Reveal.on 'fragmentshown', (e) ->
  return unless e.fragment.classList.contains 'robotpivot'
  animatePivots e.fragment.dataset.target, e.fragment.dataset.pivots, false

Reveal.on 'fragmenthidden', (e) ->
  return unless e.fragment.classList.contains 'robotpivot'
  animatePivots e.fragment.dataset.target, e.fragment.dataset.pivots, true
