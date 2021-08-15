//require jquery3
//require jquery_ujs
//require popper
//require bootstrap
//= require ahoy

ahoy.trackAll();

// https://stackoverflow.com/a/51190453/368144 simple namespacing
window.namespace = (name) =>
  name
    .split(".")
    .reduce((last, next) => (last[next] = last[next] || {}), window);

window.getWidthOf = function (id) {
  return document.getElementById(id).clientWidth;
};

window.throttle = function (cb, limit) {
  var wait = false;

  return () => {
    if (!wait) {
      requestAnimationFrame(cb);
      wait = true;
      setTimeout(() => {
        wait = false;
      }, limit);
    }
  };
};

window.chartResize = function (chart, id) {
  let newWidth = window.getWidthOf(id);
  let newSize = { width: newWidth, height: 400 };
  chart.setSize(newSize);
};
