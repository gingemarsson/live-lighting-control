defmodule LiveLightingControlWeb.ConfigCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS

  def get_border_color(enabled) do
    if enabled do
      "border-orange-600"
    else
      "border-neutral-600 hover:border-neutral-400"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-sm font-semibold">Config</h2>
      </div>

      <div id={"hidden-content-#{@id}"}>
        <div class="flex flex-row gap-2 p-2">
          <div
            class={"bg-neutral-800 p-2 w-36 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(@config.enable_programmer)}"}
            phx-click="toggle_config"
            phx-value-config-name="enable_programmer"
          >
            <p class="text-sm">Programmer</p>
          </div>
          <div
            class={"bg-neutral-800 p-2 w-36 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(@config.enable_scenes)}"}
            phx-click="toggle_config"
            phx-value-config-name="enable_scenes"
          >
            <p class="text-sm">Scenes</p>
          </div>
          <div
            class={"bg-neutral-800 p-2 w-36 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(@config.enable_sacn_output)}"}
            phx-click="toggle_config"
            phx-value-config-name="enable_sacn_output"
          >
            <p class="text-sm">sACN Output</p>
          </div>

          <div class="flex-grow" />

          <%= for view <- Map.values(@views) do %>
            <div
              class="bg-neutral-800 w-36 p-2 rounded-lg flex flex-col items-center justify-center border text-center transition-colors cursor-pointer border-neutral-600 hover:border-neutral-400"
              phx-click="toggle_select_view"
              phx-value-view-id={view.id}
            >
              <p class="text-sm">{view.label}</p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
