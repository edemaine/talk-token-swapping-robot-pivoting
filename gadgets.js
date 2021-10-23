(function() {
  var id, leftReverse, leftToRight, leftTrigger, reverseSteps, rightReverse, rightToLeft, rightTrigger, steps;

  id = function(target, x) {
    return SVG(`section.present ${target ? '#' + target : ''} .${x}`);
  };

  leftTrigger = function(target) {
    return id(target, 'agent').animate().dmove(0, 115).after(function() {
      id(target, 'leftDown').animate().opacity(0);
      id(target, 'rightDown').animate().opacity(0);
      id(target, 'rightSegment').animate().opacity(0);
      return id(target, 'leftUp').animate().opacity(1);
    });
  };

  leftReverse = function(target) {
    return id(target, 'agent').animate().dmove(0, -115).after(function() {
      id(target, 'leftDown').animate().opacity(1);
      id(target, 'rightDown').animate().opacity(1);
      id(target, 'rightSegment').animate().opacity(1);
      return id(target, 'leftUp').animate().opacity(0);
    });
  };

  rightTrigger = function(target) {
    return id(target, 'agent').animate().dmove(0, 115).after(function() {
      id(target, 'rightDown').animate().opacity(0);
      id(target, 'leftDown').animate().opacity(0);
      id(target, 'leftSegment').animate().opacity(0);
      return id(target, 'rightUp').animate().opacity(1);
    });
  };

  rightReverse = function(target) {
    return id(target, 'agent').animate().dmove(0, -115).after(function() {
      id(target, 'rightDown').animate().opacity(1);
      id(target, 'leftDown').animate().opacity(1);
      id(target, 'leftSegment').animate().opacity(1);
      return id(target, 'rightUp').animate().opacity(0);
    });
  };

  leftToRight = function(target) {
    return id(target, 'agent').animate().dmove(40, 0);
  };

  rightToLeft = function(target) {
    return id(target, 'agent').animate().dmove(-40, 0);
  };

  steps = [leftTrigger, leftReverse, leftToRight, rightTrigger, rightReverse];

  reverseSteps = [leftReverse, leftTrigger, rightToLeft, rightReverse, rightTrigger];

  Reveal.on('fragmentshown', function(e) {
    if (!e.fragment.classList.contains('L2T')) {
      return;
    }
    return steps[e.fragment.dataset.step](e.fragment.dataset.target);
  });

  Reveal.on('fragmenthidden', function(e) {
    if (!e.fragment.classList.contains('L2T')) {
      return;
    }
    return reverseSteps[e.fragment.dataset.step](e.fragment.dataset.target);
  });

}).call(this);
