defmodule LiveLightingControlWeb.FixturesLibraryCardComponent do
  use Phoenix.LiveComponent

  def get_border_color(fixture_id, selected_fixture_ids) do
    if fixture_id in selected_fixture_ids do
      "border-orange-600"
    else
      "border-neutral-600 hover:border-neutral-400"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-3 rounded-t-lg flex items-center justify-center h-full">
        <h2 class="text-lg font-semibold">Fixture Library</h2>
      </div>
      <div class="grid grid-cols-10 gap-2 p-2">
        <%= for fixture <- @fixtures do %>
          <div
            class={"bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(fixture.id, @selected_fixture_ids)}"}
            phx-click="toggle_select_fixture"
            phx-value-fixture-id={fixture.id}
            >
            <p class="text-sm text-gray-400"><%= fixture.label %></p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
