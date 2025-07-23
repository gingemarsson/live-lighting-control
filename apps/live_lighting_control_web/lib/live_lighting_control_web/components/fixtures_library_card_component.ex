defmodule LiveLightingControlWeb.FixturesLibraryCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias LiveLightingControl.Utils

  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-sm font-semibold">Fixture library</h2>
      </div>

      <div id={"hidden-content-#{@id}"}>
        <div class="grid grid-cols-10 gap-2 p-2">
          <%= for %{id: fixture_id, label: label} <- Enum.sort_by(@fixtures, & &1.label) do %>
            <div
              class={"bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{Utils.get_fixture_border_color(fixture_id, @selected_fixture_ids, @primary_selected_fixture_id)}"}
              phx-click="click_entity"
              phx-value-entity-id={fixture_id}
              phx-value-entity-type="fixture"
            >
              <p class={"text-sm #{if fixture_id == @primary_selected_fixture_id do "font-bold" end}"}>
                {label}
              </p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
