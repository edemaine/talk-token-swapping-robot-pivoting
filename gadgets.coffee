id = (target, x) -> SVG("##{target} .#{x}")

leftTrigger = (target) ->
  id(target, 'agent').animate().dmove 0, 115
  .after ->
    id(target, 'leftDown').animate().opacity 0
    id(target, 'rightDown').animate().opacity 0
    id(target, 'rightSegment').animate().opacity 0
    id(target, 'leftUp').animate().opacity 1

leftReverse = (target) ->
  id(target, 'agent').animate().dmove 0, -115
  .after ->
    id(target, 'leftDown').animate().opacity 1
    id(target, 'rightDown').animate().opacity 1
    id(target, 'rightSegment').animate().opacity 1
    id(target, 'leftUp').animate().opacity 0

rightTrigger = (target) ->
  id(target, 'agent').animate().dmove 0, 115
  .after ->
    id(target, 'rightDown').animate().opacity 0
    id(target, 'leftDown').animate().opacity 0
    id(target, 'leftSegment').animate().opacity 0
    id(target, 'rightUp').animate().opacity 1

rightReverse = (target) ->
  id(target, 'agent').animate().dmove 0, -115
  .after ->
    id(target, 'rightDown').animate().opacity 1
    id(target, 'leftDown').animate().opacity 1
    id(target, 'leftSegment').animate().opacity 1
    id(target, 'rightUp').animate().opacity 0

leftToRight = (target) ->
  id(target, 'agent').animate().dmove 40, 0
rightToLeft = (target) ->
  id(target, 'agent').animate().dmove -40, 0

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
  steps[e.fragment.dataset.step](e.fragment.dataset.target)

Reveal.on 'fragmenthidden', (e) ->
  return unless e.fragment.classList.contains 'L2T'
  reverseSteps[e.fragment.dataset.step](e.fragment.dataset.target)
