defmodule LiveLightingControlWeb.ScenesLibraryCardComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-3 rounded-t-lg flex items-center justify-center h-full">
        <h2 class="text-lg font-semibold">Scene Library</h2>
      </div>
      <div class="grid grid-cols-5 gap-2 p-2">
        <%= for scene <- @scenes do %>
          <div
            class={"bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors border-neutral-600"}
            >
            <p class="text-sm text-gray-400"><%= scene.label %></p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
