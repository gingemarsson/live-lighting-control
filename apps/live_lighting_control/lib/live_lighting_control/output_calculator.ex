defmodule LiveLightingControl.OutputCalculator do
  alias LiveLightingControl.Scene

  def calculate_output(config, scenes, programmer, fixtures_map, fixture_types_map, universe_number) do
    merged_control_data =
      case {config.enable_scenes, config.enable_programmer} do
        {true, true} -> Map.merge(merge_scenes(scenes), programmer, fn _key, v1, v2 -> Map.merge(v1, v2) end)
        {true, false} -> merge_scenes(scenes)
        {false, true} -> programmer
        {false, false} -> %{}
      end

    fixtures = Map.values(fixtures_map)
    fixtures_for_universe = Enum.filter(fixtures, &(&1.universe == universe_number))

    # calculate list of maps, one for each fixtures
    all_channels =
      Enum.map(fixtures_for_universe, fn fixture ->
        fixture_type = Map.get(fixture_types_map, fixture.fixture_type_id)
        fixture_attribute_values = Map.get(merged_control_data, fixture.id)

        channels =
          Enum.map(fixture_type.channels, fn channel ->
            dmx_channel = fixture.dmx_address + channel.dmx_address
            value = Access.get(fixture_attribute_values, channel.attribute)

            {dmx_channel, value || channel.default_value}
          end)

        Map.new(channels)
      end)

    # merge maps
    merged_channels = Enum.reduce(all_channels, %{}, &Map.merge/2)
    default_values = List.to_tuple(List.duplicate(0, 512))

    dmx_values =
      Enum.reduce(merged_channels, default_values, fn {index, value}, acc ->
        put_elem(acc, index - 1, value)
      end)
      |> Tuple.to_list()

    dmx_values
  end

  defp merge_scenes(scenes) do
      scenes
      |> Enum.filter(&(&1.state.master > 0))
      |> Enum.map(&compute_scene_values/1)
      |> Enum.reduce(%{}, &htp_fixture_merge/2)
  end

  defp compute_scene_values(%Scene{fixtures: fixture_map, state: state}) do
    scaled_by_scene_master =
        Enum.into(fixture_map, %{}, fn {guid, attributes_map} ->
          updated = attributes_map
            |> Enum.map(fn {key, value} -> {key, value * state.master * 0.01} end)
            |> Enum.into(%{})

          {guid, updated}
        end)

    scaled_by_scene_master
  end

  defp htp_fixture_merge(map_1, map_2) do
    Map.merge(map_1, map_2, fn _key, v1, v2 -> htp_merge(v1, v2) end)
  end

  defp htp_merge(map_1, map_2) do
    Map.merge(map_1, map_2, fn _key, v1, v2 -> max(v1, v2) end)
  end
end
