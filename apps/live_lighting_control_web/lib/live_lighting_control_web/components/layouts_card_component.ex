defmodule LiveLightingControlWeb.LayoutsCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias LiveLightingControl.Utils

  def get_layout_border_color(layout, layouts, selected_layout_id_or_nil) do
    selected_layout_id = get_selected_layout_id(layouts, selected_layout_id_or_nil)

    if layout.id == selected_layout_id do
      "border-orange-600"
    else
      "border-neutral-600 hover:border-neutral-400"
    end
  end

  def get_selected_layout_id(layouts, selected_layout_id_or_nil) do
    selected_layout_id_or_nil || List.first(Map.values(layouts)).id
  end

  def get_selected_layout(layouts, selected_layout_id_or_nil) do
    selected_layout_id = get_selected_layout_id(layouts, selected_layout_id_or_nil)
    Map.get(layouts, selected_layout_id)
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-sm font-semibold">Layout view</h2>
      </div>

      <% selected_layout_id = Map.get(@configuration, :selected_layout_id, nil) %>
      <% selected_layout = get_selected_layout(@layouts_map, selected_layout_id) %>

      <div id={"hidden-content-#{@id}"}>
        <div class="grid grid-cols-10 gap-2 p-2">
          <%= for layout <- Map.values(@layouts_map) do %>
            <div
              class={"bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_layout_border_color(layout, @layouts_map, selected_layout_id)}"}
              phx-click="update_card_configuration"
              phx-value-value={layout.id}
              phx-value-key="selected_layout_id"
              phx-value-card-id={@id}
            >
              <p class="text-sm">{layout.label}</p>
            </div>
          <% end %>
        </div>

        <div class="overflow-hidden">
          <div class="m-8">
            <div class="relative w-full" style="height: 500px;">
              <%= for {fixture_id, %{x: x, y: y, label: label}} <- selected_layout.fixtures do %>
                <div
                  class={"absolute text-white text-lg px-2 py-1 cursor-pointer rounded-lg border #{Utils.get_fixture_border_color(fixture_id, @selected_fixture_ids, @primary_selected_fixture_id)}"}
                  style={"left: #{x}%; top: #{y}%; transform: translate(-50%, -50%);"}
                  phx-click="click_entity"
                  phx-value-entity-id={fixture_id}
                  phx-value-entity-type="fixture"
                >
                  {label}
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
