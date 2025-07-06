
// HOOKS

let Hooks = {}

Hooks.VerticalSlider = {
  mounted() {
    const slider = this.el;
    const sliderId = slider.dataset.sliderId;
    const sliderType = slider.dataset.sliderType;
    const sendValue = (value) => {
      this.pushEvent("slider_changed", { value, sliderId, sliderType });
    };

    const getValueFromY = (clientY) => {
      const rect = slider.getBoundingClientRect();
      const offset = rect.bottom - clientY;
      let percent = (offset / rect.height) * 100;
      percent = Math.max(0, Math.min(100, percent));
      return Math.round(percent);
    };

    const onMove = (e) => {
      e.preventDefault();
      const clientY = e.touches ? e.touches[0].clientY : e.clientY;
      const value = getValueFromY(clientY);
      sendValue(value);
    };

    const onUp = () => {
      window.removeEventListener("mousemove", onMove);
      window.removeEventListener("mouseup", onUp);
      window.removeEventListener("touchmove", onMove);
      window.removeEventListener("touchend", onUp);
    };

    slider.addEventListener("mousedown", (e) => {
      onMove(e);
      window.addEventListener("mousemove", onMove);
      window.addEventListener("mouseup", onUp);
    });

    slider.addEventListener("touchstart", (e) => {
      onMove(e);
      window.addEventListener("touchmove", onMove);
      window.addEventListener("touchend", onUp);
    });
  }
};


// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


