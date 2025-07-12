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
    <div class="bg-neutral-700 p-2 rounded-t-lg">
        <h2 class="text-sm font-semibold">Fixture library</h2>
      </div>

      <div class="grid grid-cols-10 gap-2 p-2">
        <%= for fixture <- @fixtures do %>
          <div
            class={"bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(fixture.id, @selected_fixture_ids)}"}
            phx-click="toggle_select_fixture"
            phx-value-fixture-id={fixture.id}
            >
            <p class="text-sm"><%= fixture.label %></p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
