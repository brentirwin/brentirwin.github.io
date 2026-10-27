// Shrinks each layered chart group (_includes/chart-stack.html) to fit
// narrow screens. The charts stay laid out at full size and are scaled as
// one picture, so overlays stay exactly where you put them.
(function () {
  var stacks = document.querySelectorAll('.chart-stack');

  function fit() {
    stacks.forEach(function (stack) {
      var W = Number(stack.dataset.width), H = Number(stack.dataset.height);
      var scale = Math.min(1, stack.clientWidth / W);
      stack.querySelector('.chart-stack-frame').style.transform = 'scale(' + scale + ')';
      stack.querySelector('.chart-stack-sizer').style.height = (H * scale) + 'px';
    });
  }

  fit();
  window.addEventListener('resize', fit);
})();
