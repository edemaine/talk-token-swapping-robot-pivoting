window.addEventListener 'DOMContentLoaded', ->
  square = (className) ->
    if className.startsWith 'robot'
      z = 1
    else
      z = 0
    """
      <symbol viewBox="0 0 1 1" overflowBox="-0.1 -0.1 1.2 1.2" z-index="#{z}">
        <rect width="1" height="1" class="#{className}"/>
      </symbol>
    """
  mapping = new svgtiler.Mapping
    O: square 'robot'
    1: square 'robot r1'
    x: square 'bad'
    '.': square 'empty'
  svgtiler.renderDOM mapping, '.robots',
    filename: 'robots.asc'
    keepParent: true
