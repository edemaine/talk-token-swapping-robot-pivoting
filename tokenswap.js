(function() {

  /*
  initCircles = ->
    ## Remember original location of all circles
    for elt in document.querySelectorAll 'circle'
      continue if elt.hasAttribute 'data-cx'
      elt.setAttribute 'data-cx', elt.getAttribute 'cx'
      elt.setAttribute 'data-cy', elt.getAttribute 'cy'
   */
  var animateSwaps, swapDelay, swapDuration, timeline;

  swapDuration = 500;

  swapDelay = 100;

  timeline = null;

  animateSwaps = function(swaps, reverse) {
    var centers, count, i, j, k, len, results, swap, ti, tj;
    //initCircles()
    swaps = swaps.split(/\s+/);
    if (reverse) {
      swaps.reverse();
    }
    centers = {};
    if (timeline != null) {
      timeline.finish();
    }
    timeline = new SVG.Timeline();
    results = [];
    for (count = k = 0, len = swaps.length; k < len; count = ++k) {
      swap = swaps[count];
      if (!swap) {
        continue;
      }
      [i, j] = swap.split(',');
      i = parseInt(i);
      j = parseInt(j);
      if (isNaN(i) || isNaN(j)) {
        console.warn(`Invalid swap ${swap}`);
        continue;
      }
      ti = SVG(`section.present circle.t${i}`);
      tj = SVG(`section.present circle.t${j}`);
      if (!((ti != null) && (tj != null))) {
        continue;
      }
      ti.timeline(timeline);
      tj.timeline(timeline);
      if (centers[i] == null) {
        centers[i] = [ti.cx(), ti.cy()];
      }
      if (centers[j] == null) {
        centers[j] = [tj.cx(), tj.cy()];
      }
      //# Swap
      [centers[i], centers[j]] = [centers[j], centers[i]];
      ti.animate(swapDuration, swapDelay, 'after').center(...centers[i]);
      results.push(tj.animate(swapDuration, -swapDuration, 'after').center(...centers[j]));
    }
    return results;
  };

  Reveal.on('fragmentshown', function(e) {
    if (!e.fragment.classList.contains('tokenswap')) {
      return;
    }
    return animateSwaps(e.fragment.dataset.swaps, false);
  });

  Reveal.on('fragmenthidden', function(e) {
    if (!e.fragment.classList.contains('tokenswap')) {
      return;
    }
    return animateSwaps(e.fragment.dataset.swaps, true);
  });

}).call(this);
