// Drag-to-arrange mode for layered charts (_includes/chart-stack.html).
// Only runs when the page URL ends in ?arrange, e.g. /japanese/?arrange.
// Drag the top charts into place, then copy the numbers shown under each
// group into _data/japanese_charts.yml. Nothing is saved by the page itself.
(function () {
  if (!/[?&]arrange\b/.test(location.search)) return;

  document.querySelectorAll('.chart-stack').forEach(function (stack) {
    var W = Number(stack.dataset.width);
    var frame = stack.querySelector('.chart-stack-frame');
    var items = Array.prototype.slice.call(stack.querySelectorAll('.chart-stack-item'));
    var output = document.createElement('pre');
    output.className = 'chart-arrange-output';
    stack.appendChild(output);
    stack.classList.add('is-arranging');

    function place(el) {
      var d = el.dataset;
      el.style.left = d.x + 'px';
      el.style.top = d.y + 'px';
      el.style.width = d.w + 'px';
      el.style.height = d.h + 'px';
    }

    function render() {
      output.textContent = items.map(function (el) {
        var d = el.dataset;
        return '- title: ' + d.title + '\n' +
               '  x: ' + d.x + '\n  y: ' + d.y + '\n' +
               '  width: ' + d.w + '\n  height: ' + d.h;
      }).join('\n');
    }

    items.forEach(function (el, i) {
      // Use each image's real size, so you don't have to type it in.
      if (el.tagName === 'IMG') {
        el.draggable = false;
        var useNaturalSize = function () {
          if (!el.naturalWidth || i === 0) return;
          el.dataset.w = el.naturalWidth;
          el.dataset.h = el.naturalHeight;
          place(el);
          render();
        };
        if (el.complete) useNaturalSize(); else el.addEventListener('load', useNaturalSize);
      }
      if (i === 0) return; // the bottom chart stays put

      el.classList.add('is-draggable');
      el.addEventListener('pointerdown', function (down) {
        down.preventDefault();
        el.setPointerCapture(down.pointerId);
        var scale = W / frame.getBoundingClientRect().width; // screen pixels -> chart pixels
        var startX = Number(el.dataset.x), startY = Number(el.dataset.y);

        function move(e) {
          el.dataset.x = Math.round(startX + (e.clientX - down.clientX) * scale);
          el.dataset.y = Math.round(startY + (e.clientY - down.clientY) * scale);
          place(el);
          render();
        }
        function up() {
          el.removeEventListener('pointermove', move);
          el.removeEventListener('pointerup', up);
        }
        el.addEventListener('pointermove', move);
        el.addEventListener('pointerup', up);
      });
    });

    render();
  });
})();
