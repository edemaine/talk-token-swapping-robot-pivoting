# This rendering needs to happen before any .robotpivot.fragment,
# so we call it before Reveal.initialize() in index.pug.
#window.addEventListener 'DOMContentLoaded', ->
window.renderFigures = ->
  zIndex = (className) ->
    if className?
      if className?.startsWith 'robot'
        1
      else
        0
    else
      -1

  mapping = (construct) ->
    new svgtiler.Mapping
      O: construct 'robot'
      1: construct 'robot r1'
      x: construct 'bad'
      '.': construct 'empty'
      ' ': construct()

  square = (className) ->
    """
      <symbol viewBox="0 0 1 1" overflowBox="-0.1 -0.1 1.2 1.2" z-index="#{zIndex className}">
        <rect width="1" height="1" class="#{className}"/>
      </symbol>
    """
  svgtiler.renderDOM mapping(square), '.robots',
    filename: 'robots.asc'
    keepParent: true

  hexX = 1.5/2
  hexY = Math.sin(Math.PI*4/6)/2   # 0.8660254037844386/2
  hexagon = (className) ->
    """
      <symbol viewBox="#{-hexX/2} #{-hexY} #{hexX} #{hexY}" overflowBox="#{-0.5-0.1} #{-hexY-0.1} #{2*(0.5+0.1)} #{2*(hexY+0.1)}" z-index="#{zIndex className}">
        #{if className?
          """<polygon points="0.5,0 0.25,#{hexY} -0.25,#{hexY} -0.5,0 -0.25,#{-hexY} 0.25,#{-hexY}" class="#{className}"/>"""
        else ''}
      </symbol>
    """
  svgtiler.renderDOM mapping(hexagon), '.hexrobots',
    filename: 'hexrobots.asc'
    keepParent: true
  for symbol in document.querySelectorAll '.hexrobots > svg > symbol'
    symbol.id = "h#{symbol.id}"
  for use in document.querySelectorAll '.hexrobots > svg > use'
    use.setAttribute 'href', "#h#{use.getAttribute('href')[1..]}"
  undefined
