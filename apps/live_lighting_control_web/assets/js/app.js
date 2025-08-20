
// HOOKS

let Hooks = {}

Hooks.SetValue = {
  mounted() {
    this.handleEvent("set-value", ({ value }) => {
      this.el.value = value || ""
    })
  }
}

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
      let value = (offset / rect.height) * 255;
      value = Math.max(0, Math.min(255, value));
      return Math.round(value * 1000) / 1000;
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

Hooks.ColorPickerHook = {
  mounted() {
    this.initColorPicker();
  },

  initColorPicker() {
    const colorpicker = this.el;
    const colorPickerType = colorpicker.dataset.colorPickerType;

    const red = this.el.dataset.red;
    const green = this.el.dataset.green;
    const blue = this.el.dataset.blue;

    this.picker = new iro.ColorPicker(this.el, {
      width: 280,
      layoutDirection: 'horizontal',
      layout: [
        {
          component: iro.ui.Wheel,
        },
        {
          component: iro.ui.Slider,
          options: {
            sliderType: 'hue',
            sliderSize: 40,
          }
        },
        {
          component: iro.ui.Slider,
          options: {
            sliderType: 'saturation',
            sliderSize: 40,
          }
        },
        {
          component: iro.ui.Slider,
          options: {
            sliderType: 'value',
            sliderSize: 40,
          }
        },
        {
          component: iro.ui.Slider,
          options: {
            sliderType: 'kelvin',
            sliderSize: 40,
          }
        },
      ],
      color: {r: red, g: green, b: blue}
    });

    this.picker.on('color:change', (color) => {
      const { r, g, b } = color.rgb;
      this.pushEvent("color_changed", { colorPickerType, red: r, green: g, blue: b});
    });
  },


  destroyed() {
    //this.picker && this.picker.destroy();
  }
}

Hooks.ExecutorButtonHook = {
  mounted() {
    this.el.addEventListener("mousedown", () => {
      this.pushEvent("trigger_executor_action_button_down", { executorId: this.el.dataset.executorId });
    });

    this.el.addEventListener("mouseup", () => {
      this.pushEvent("trigger_executor_action_button_up", { executorId: this.el.dataset.executorId  });
    });
  }
};

Hooks.MidiHook = {
  mounted() {
    if (!navigator.requestMIDIAccess) {
      console.warn("Web MIDI API not supported.");
      return;
    }

    navigator.requestMIDIAccess().then((midiAccess) => {
      for (let input of midiAccess.inputs.values()) {
        input.onmidimessage = (message) => {
          const [status, data1, data2] = message.data;

          const midi_event_data = {
            status,
            data1,
            data2,
            timestamp: message.timeStamp
          }

          this.pushEvent("midi_event", midi_event_data);
        };
      }
    });
  }
}


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


