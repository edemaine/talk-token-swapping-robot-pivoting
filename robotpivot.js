(function() {
  // Pivot format: <use x>,<use y>/<angle to rotate>@<center x>,<center y>
  // Can specify multiple /...@... rotation actions
  var animatePivots, hexCorners, parseXY, pivotDelay, pivotDuration, pivotFade, pivotRadius, timeline;

  pivotDuration = {
    60: 300,
    90: 500,
    120: 500,
    180: 600
  };

  pivotDelay = 100;

  pivotFade = 100;

  pivotRadius = 0.15;

  timeline = null;

  parseXY = function(coords) {
    var x, y;
    [x, y] = coords.split(',');
    x = parseFloat(x);
    y = parseFloat(y);
    if (isNaN(x) || isNaN(y)) {
      console.warn(`Invalid coordinates ${coords}`);
    }
    return {x, y};
  };

  hexCorners = {
    C: {
      x: hexX / 2,
      y: hexY // negative of first two entries of hexagon viewBox
    },
    // All remaining corners are relative to the center above:
    R: {
      x: 0.5,
      y: 0
    },
    BR: {
      x: 0.25,
      y: hexY
    },
    BL: {
      x: -0.25,
      y: hexY
    },
    L: {
      x: -0.5,
      y: 0
    },
    TL: {
      x: -0.25,
      y: -hexY
    },
    TR: {
      x: 0.25,
      y: -hexY
    }
  };

  animatePivots = function(target, pivots, reverse) {
    var angle, center, centerString, i, id, j, k, len, len1, parseCoords, pivot, pivotCenter, robot, root, rotation, rotations, select, selector, svg, transform, transforms, use;
    if (timeline != null) {
      timeline.finish();
    }
    timeline = new SVG.Timeline();
    root = document.querySelector(`section.present #${target}`);
    if (root == null) {
      return console.warn(`Invalid target ${target}`);
    }
    svg = SVG(`section.present #${target} > svg`);
    pivotCenter = svg.circle(2 * pivotRadius).addClass('pivotCenter').opacity(0).timeline(timeline);
    if (root.classList.contains('hexrobots')) {
      parseCoords = function(coords) {
        var match, parsed, x, y;
        if ((match = /^(T|B)?(L|R)|C/.exec(coords)) != null) {
          ({x, y} = hexCorners[match[0]]);
          coords = coords.slice(match[0].length);
          x += hexCorners.C.x;
          y += hexCorners.C.y;
        } else {
          x = y = 0;
        }
        parsed = parseXY(coords);
        x += parsed.x * hexX;
        y += parsed.y * hexY;
        return {x, y};
      };
      select = function(x) {
        var s;
        s = (Math.trunc(100 * x) / 100).toFixed(2);
        if (s.endsWith('0')) {
          while (s.endsWith('0')) {
            s = s.slice(0, -1);
          }
          if (s.endsWith('.')) {
            s = s.slice(0, -1);
          }
          return `='${s}'`;
        } else {
          return `^='${s}'`;
        }
      };
    } else {
      parseCoords = parseXY;
      select = function(x) {
        return `='${x.toFixed(0)}'`;
      };
    }
    pivots = pivots.split(/\s+/);
    if (reverse) {
      pivots.reverse();
    }
    transforms = {};
    for (j = 0, len = pivots.length; j < len; j++) {
      pivot = pivots[j];
      if (!pivot) {
        continue;
      }
      [use, ...rotations] = pivot.split('/');
      use = parseCoords(use);
      selector = `section.present #${target} use[x${select(use.x)}][y${select(use.y)}]`;
      robot = SVG(selector);
      if (robot == null) {
        console.warn(`Failed to select ${selector}`);
        continue;
      }
      robot.timeline(timeline);
      id = `${use.x},${use.y}`;
      if (transforms[id] == null) {
        transforms[id] = new SVG.Matrix(robot.transform());
      }
      if (reverse) {
        rotations.reverse();
      }
      rotations = (function() {
        var k, len1, results;
        results = [];
        for (k = 0, len1 = rotations.length; k < len1; k++) {
          rotation = rotations[k];
          results.push(rotation.split('@'));
        }
        return results;
      })();
      for (i = k = 0, len1 = rotations.length; k < len1; i = ++k) {
        [angle, centerString] = rotations[i];
        angle = parseFloat(angle);
        if (isNaN(angle)) {
          console.warn(`Invalid angle ${angle}`);
          continue;
        }
        if (reverse) {
          angle = -angle;
        }
        center = parseCoords(centerString);
        if (!(i > 0 && rotations[i - 1][1] === centerString)) {
          pivotCenter.animate(0.1, 0, 'after').attr({
            cx: center.x,
            cy: center.y
          });
          pivotCenter.animate(pivotFade, 0, 'after').opacity(1);
        }
        center = new SVG.Point(center).transform(transforms[id].inverse());
        //# Pivot
        transform = {
          rotate: angle,
          originX: center.x,
          originY: center.y
        };
        robot.animate(pivotDuration[Math.abs(angle)], pivotDelay, 'after').during((function(robot) {
          return function(t) {
            if (robot.node.style.filter !== "hue-rotate(90deg)") {
              return robot.node.style.filter = `hue-rotate(${t * 90}deg)`;
            }
          };
        })(robot)).transform(transform, true); // relative to previous transformations
        transforms[id] = transforms[id].transform(transform);
        if (!(i < rotations.length - 1 && rotations[i + 1][1] === centerString)) {
          pivotCenter.animate(pivotFade, 0, 'after').opacity(0);
        }
      }
    }
    return pivotCenter.animate(0.1, 0, 'last').after(function() {
      return pivotCenter.remove();
    });
  };

  Reveal.on('fragmentshown', function(e) {
    if (!e.fragment.classList.contains('robotpivot')) {
      return;
    }
    return animatePivots(e.fragment.dataset.target, e.fragment.dataset.pivots, false);
  });

  Reveal.on('fragmenthidden', function(e) {
    if (!e.fragment.classList.contains('robotpivot')) {
      return;
    }
    return animatePivots(e.fragment.dataset.target, e.fragment.dataset.pivots, true);
  });

}).call(this);
