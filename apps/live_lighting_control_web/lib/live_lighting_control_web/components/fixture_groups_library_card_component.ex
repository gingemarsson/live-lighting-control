defmodule LiveLightingControlWeb.FixtureGroupsLibraryCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias LiveLightingControl.Utils

  def get_border_color(fixture_group, selected_fixture_ids) do
    case Utils.is_fixtures_selected?(fixture_group.fixture_ids, selected_fixture_ids) do
      :all ->
        "border-orange-600"

      :some ->
        "border-yellow-600"

      _ ->
        "border-neutral-600 hover:border-neutral-400"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-sm font-semibold">Group library</h2>
      </div>

      <div id={"hidden-content-#{@id}"}>
        <div class="grid grid-cols-10 gap-2 p-2">
          <%= for fixture_group <- @fixture_groups do %>
            <div
              class={"bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(fixture_group, @selected_fixture_ids)}"}
              phx-click="click_entity"
              phx-value-entity-id={fixture_group.id}
              phx-value-entity-type="fixture_group"
            >
              <p class="text-sm">{fixture_group.label}</p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
