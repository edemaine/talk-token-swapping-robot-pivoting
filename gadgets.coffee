id = (x) -> SVG("##{x}")

leftTrigger = ->
  id('agent').animate().dmove 0, 115
  .after ->
    id('leftDown').animate().opacity 0
    id('rightDown').animate().opacity 0
    id('rightSegment').animate().opacity 0
    id('leftUp').animate().opacity 1

leftReverse = ->
  id('agent').animate().dmove 0, -115
  .after ->
    id('leftDown').animate().opacity 1
    id('rightDown').animate().opacity 1
    id('rightSegment').animate().opacity 1
    id('leftUp').animate().opacity 0

rightTrigger = ->
  id('agent').animate().dmove 0, 115
  .after ->
    id('rightDown').animate().opacity 0
    id('leftDown').animate().opacity 0
    id('leftSegment').animate().opacity 0
    id('rightUp').animate().opacity 1

rightReverse = ->
  id('agent').animate().dmove 0, -115
  .after ->
    id('rightDown').animate().opacity 1
    id('leftDown').animate().opacity 1
    id('leftSegment').animate().opacity 1
    id('rightUp').animate().opacity 0

leftToRight = ->
  id('agent').animate().dmove 40, 0
rightToLeft = ->
  id('agent').animate().dmove -40, 0

steps = [
  leftTrigger
  leftReverse
  leftToRight
  rightTrigger
  rightReverse
]
reverseSteps = [
  leftReverse
  leftTrigger
  rightToLeft
  rightReverse
  rightTrigger
]

Reveal.on 'fragmentshown', (e) ->
  return unless e.fragment.classList.contains 'L2T'
  steps[e.fragment.dataset.step]()

Reveal.on 'fragmenthidden', (e) ->
  return unless e.fragment.classList.contains 'L2T'
  reverseSteps[e.fragment.dataset.step]()
