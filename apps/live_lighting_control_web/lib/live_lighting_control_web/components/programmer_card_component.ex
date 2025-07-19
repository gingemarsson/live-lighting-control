defmodule LiveLightingControlWeb.ProgrammerCardComponent do
  use Phoenix.LiveComponent

  defp get_fixture_attributes(fixtures, selected_fixture_ids, fixture_types) do
    selected_fixture_type_ids =
      LiveLightingControl.Utils.get_selected_fixtures(fixtures, selected_fixture_ids)
      |> Enum.map(& &1.fixture_type_id)

    fixture_attributes =
      Enum.filter(fixture_types, &(&1.id in selected_fixture_type_ids))
      |> Enum.flat_map(& &1.channels)
      |> Enum.map(& &1.attribute)
      |> Enum.uniq()

    fixture_attributes
  end

  defp get_values_for_attibute(attribute, programmer, selected_fixture_ids) do
    Enum.map(selected_fixture_ids, fn fixture_id -> Map.get(programmer, fixture_id) end)
    |> Enum.map(fn fixture_programmer -> Access.get(fixture_programmer, attribute) end)
    |> Enum.map(&(&1 || 0))
  end

  defp get_min_value_for_attibute(attribute, programmer, selected_fixture_ids) do
    get_values_for_attibute(attribute, programmer, selected_fixture_ids)
    |> Enum.reduce(255, &min/2)
  end

  defp get_max_value_for_attibute(attribute, programmer, selected_fixture_ids) do
    get_values_for_attibute(attribute, programmer, selected_fixture_ids)
    |> Enum.reduce(0, &max/2)
  end

  def format_min_max(min, max) when min == max, do: "#{round(min)}"
  def format_min_max(min, max), do: "#{round(min)}-#{round(max)}"

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
      <div class="absolute bottom-0 left-0 w-full bg-blue-400 rounded" style={"height: #{@value}%"}>
      </div>
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

  def supports_rgb?(attributes_for_fixture) do
    required = MapSet.new(["red", "green", "blue"])
    MapSet.subset?(required, MapSet.new(attributes_for_fixture))
  end

  def render(assigns) do
    ~H"""
    <div class="w-full flex flex-col h-96">
      <div class="bg-neutral-700 p-2 rounded-t-lg flex flex-row">
        <h2 class="text-sm font-semibold">Programmer</h2>
        <button class="text-xs m-0 mx-2 px-3 py-1 rounded-sm border border-neutral-600 hover:border-neutral-400 active:border-orange-600 text-white font-semibold transition-colors" phx-click="clear-programmer">
          Clear Programmer
        </button>
      </div>

      <div class="flex flex-row flex-grow gap-2 m-2">
        <% attributes = get_fixture_attributes(@fixtures, @selected_fixture_ids, @fixture_types) %>
        <% supports_rgb = supports_rgb?(attributes) %>
        <%= for attribute <- attributes do %>
          <div class="bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors border-neutral-600">
            <p class={"text-sm #{ if 0 == 0 do "text-gray-500" else "" end}"}>
              {attribute}
            </p>

            <div class="text-sm text-gray-700 font-medium">
              {format_min_max(
                get_min_value_for_attibute(attribute, @programmer, @selected_fixture_ids),
                get_max_value_for_attibute(attribute, @programmer, @selected_fixture_ids)
              )}
            </div>

            <form class="w-12 h-full">
              <.live_component
                module={LiveLightingControlWeb.VerticalSliderComponent}
                id={attribute}
                value={get_max_value_for_attibute(attribute, @programmer, @selected_fixture_ids) / 2.55}
                slider_id={attribute}
                slider_type={:programmer}
              />
            </form>
          </div>
        <% end %>

        <%= if supports_rgb do %>
          <div class="bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors border-neutral-600" id="wrapper" phx-update="ignore">
            <div
              id="color-picker"
              phx-hook="ColorPickerHook"
              data-color-picker-type={:programmer}
              data-red={get_max_value_for_attibute("red", @programmer, @selected_fixture_ids)}
              data-green={get_max_value_for_attibute("green", @programmer, @selected_fixture_ids)}
              data-blue={get_max_value_for_attibute("blue", @programmer, @selected_fixture_ids)}
            ></div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
