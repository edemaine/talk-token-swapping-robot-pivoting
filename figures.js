(function() {
  // Also used in robotpivot.coffee
  window.hexX = 1.5 / 2;

  window.hexY = Math.sin(Math.PI * 4 / 6) / 2; // 0.8660254037844386/2

  
  // This rendering needs to happen before any .robotpivot.fragment,
  // so we call it before Reveal.initialize() in index.pug.
  //window.addEventListener 'DOMContentLoaded', ->
  window.renderFigures = function() {
    var hexagon, i, j, len, len1, mapping, ref, ref1, square, symbol, use, zIndex;
    zIndex = function(className) {
      if (className != null) {
        if (className != null ? className.startsWith('robot') : void 0) {
          if (className === 'robot') {
            return 1;
          } else {
            return 2;
          }
        } else {
          return 0;
        }
      } else {
        return -1;
      }
    };
    mapping = function(construct) {
      return new svgtiler.Mapping({
        O: construct('robot'),
        1: construct('robot r1'),
        2: construct('robot r2'),
        x: construct('bad'),
        '.': construct('empty'),
        ' ': construct()
      });
    };
    square = function(className) {
      return `<symbol viewBox="0 0 1 1" overflowBox="-0.1 -0.1 1.2 1.2" z-index="${zIndex(className)}">
  <rect width="1" height="1" class="${className}"/>
</symbol>`;
    };
    svgtiler.renderDOM(mapping(square), '.robots', {
      filename: 'robots.asc',
      keepParent: true
    });
    hexagon = function(className) {
      return `<symbol viewBox="${-hexX / 2} ${-hexY} ${hexX} ${hexY}" overflowBox="${-0.5 - 0.1} ${-hexY - 0.1} ${2 * (0.5 + 0.1)} ${2 * (hexY + 0.1)}" z-index="${zIndex(className)}">
  ${className != null ? `<polygon points="0.5,0 0.25,${hexY} -0.25,${hexY} -0.5,0 -0.25,${-hexY} 0.25,${-hexY}" class="${className}"/>` : ''}
</symbol>`;
    };
    svgtiler.renderDOM(mapping(hexagon), '.hexrobots', {
      filename: 'hexrobots.asc',
      keepParent: true
    });
    ref = document.querySelectorAll('.hexrobots > svg > symbol');
    for (i = 0, len = ref.length; i < len; i++) {
      symbol = ref[i];
      symbol.id = `h${symbol.id}`;
    }
    ref1 = document.querySelectorAll('.hexrobots > svg > use');
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      use = ref1[j];
      use.setAttribute('href', `#h${use.getAttribute('href').slice(1)}`);
    }
    return void 0;
  };

}).call(this);
