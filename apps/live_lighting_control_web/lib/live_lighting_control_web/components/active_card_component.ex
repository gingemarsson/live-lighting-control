defmodule LiveLightingControlWeb.ActiveCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias LiveLightingControl.Utils

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-sm font-semibold">Active</h2>
      </div>

      <div id={"hidden-content-#{@id}"}>
        <div class="grid grid-cols-10 gap-2 p-2">
          <% scenes_map = Map.new(@scenes, &{&1.id, &1}) %>
          <% cues_map = Enum.flat_map(@scenes, & &1.cues) |> Map.new(&{&1.id, &1}) %>
          <% current_time = System.os_time(:millisecond) %>

          <%= for %{id: active_id, scene_id: scene_id, cue_id: cue_id} = active_cue <- Enum.sort_by(@active, & &1.fade_in_triggered_time) do %>
            <% scene = Map.get(scenes_map, scene_id) %>
            <% cue = Map.get(cues_map, cue_id) %>
            <% fade_factor = Utils.get_fade_factor(active_cue, current_time) %>
            <% fade_factor_percent = trunc(fade_factor * 100) %>
            <div
              class="bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer border-neutral-600 hover:border-neutral-400"
              phx-click="click_entity"
              phx-value-entity-id={active_id}
              phx-value-entity-type="active"
            >
              <div class="w-full bg-neutral-600 h-0.5 mb-1 overflow-hidden">
                <div class="bg-orange-600 h-0.5" style={"width: #{fade_factor_percent}%"}></div>
              </div>
              <p class="text-sm">
                {scene.label}
              </p>
              <p class="text-xs">
                {cue.label}
              </p>
              <p class="text-xs">
                {active_cue.fade_out_completed_time}
              </p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
