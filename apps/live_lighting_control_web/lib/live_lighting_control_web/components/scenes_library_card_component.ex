defmodule LiveLightingControlWeb.ScenesLibraryCardComponent do
  use Phoenix.LiveComponent

  def vertical_slider(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="VerticalSlider"
      phx-update="ignore"
      data-value={@value}
      class="relative w-full h-full bg-gray-200 rounded cursor-pointer"
    >
      <!-- Filled portion -->
      <div
        class="absolute bottom-0 left-0 w-full bg-blue-400 rounded"
        style={"height: #{@value}%"}
      ></div>
      <!-- Thumb -->
      <div
        class="absolute left-0 w-full flex justify-center"
        style={"bottom: calc(#{@value}% - 0.5rem);"}
      >
        <div class="w-4 h-4 bg-blue-600 rounded-full shadow"></div>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="w-full flex flex-col h-96">
    <div class="bg-neutral-700 p-2 rounded-t-lg">
        <h2 class="text-sm font-semibold">Scenes</h2>
      </div>

      <div class="flex flex-row flex-grow gap-2 m-2">
        <%= for scene <- @scenes do %>
          <div
            class="bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors border-neutral-600"
            >
            <p class={"text-sm #{ if scene.state.master == 0 do "text-gray-500" else "" end}"}><%= scene.label %></p>
            <div class="text-sm text-gray-700 font-medium">
              <%= scene.state.master %>
            </div>
            <form phx-change="update_scene_state" phx-value-scene-id={scene.id} class="w-12 h-full">
              <.live_component module={LiveLightingControlWeb.VerticalSliderComponent} id={scene.id} value={scene.state.master} slider_id={scene.id} slider_type={:scene} />

            </form>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
