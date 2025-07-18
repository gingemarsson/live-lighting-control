defmodule LiveLightingControlWeb.OutputCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS

  def get_dmx_range_of_fixture(fixture_id, fixtures, fixture_types) do
    fixture = Map.get(fixtures, fixture_id)
    fixture_type = Map.get(fixture_types, fixture.fixture_type_id)
    channel_count = Enum.max_by(fixture_type.channels, & &1.dmx_address).dmx_address

    %{universe: fixture.universe, start: fixture.dmx_address, end: fixture.dmx_address + channel_count}
  end

  def get_dmx_channel_position_in_selected_fixtures(universe, channel, selected_fixture_ids, fixtures, fixture_types) do
    channels_of_selected_fixtures = Enum.map(selected_fixture_ids, fn fixture_id -> get_dmx_range_of_fixture(fixture_id, fixtures, fixture_types) end)

    Enum.find_value(channels_of_selected_fixtures, fn %{universe: u, start: s, end: e} ->
      cond do
        u == universe and channel == s and channel == e -> :single
        u == universe and channel == s -> :start
        u == universe and channel == e -> :end
        u == universe and channel > s and channel < e -> :middle
        true -> nil
      end
    end) || :outside
  end

  def border_class(:single), do: "border-orange-600"
  def border_class(:start), do: "border-l-orange-600 border-t-orange-600 border-b-orange-600 border-transparent"
  def border_class(:middle), do: "border-t-orange-600 border-b-orange-600 border-transparent"
  def border_class(:end), do: "border-r-orange-600 border-t-orange-600 border-b-orange-600 border-transparent"
  def border_class(:outside), do: "border-transparent"

  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-sm font-semibold">Output Preview</h2>
      </div>

      <div id={"hidden-content-#{@id}"}>
        <%= for {universe_number, values} <- Map.to_list(@output) do %>
          <h3 class="p-1 text-sm font-semibold">Universe {universe_number}</h3>

          <div class="grid grid-cols-64 gap-0">
            <%= for {value, channel} <- Enum.with_index(values, 1) do %>
              <% color = "rgb(#{value}, #{value}, #{value})" %>
              <% pos = get_dmx_channel_position_in_selected_fixtures(universe_number, channel, @selected_fixture_ids, @fixtures, @fixture_types) %>
              <div
                class={"flex items-center justify-center text-xs font-mono py-2 border border-2  #{border_class(pos)}"}
                style={"background-color: #{color}; color: #{if value > 128, do: "black", else: "white"};"}
              >
                {trunc(value)}
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
