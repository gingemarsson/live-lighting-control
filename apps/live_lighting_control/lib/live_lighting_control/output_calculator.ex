defmodule LiveLightingControl.OutputCalculator do
  alias LiveLightingControl.Models.Scene
  alias LiveLightingControl.Utils

  def calculate_output(
        config,
        scenes,
        programmer,
        users,
        fixtures_map,
        fixture_types_map,
        universe_number
      ) do
    highlight_data = get_highlight_data(users)

    # The merged control data is a map of fixture ids, pointing to a map of attributes pointing to values between 0 and 255
    merged_control_data =
      %{}
      |> Utils.deep_merge(if(config.enable_scenes, do: merge_scenes(scenes), else: %{}))
      |> Utils.deep_merge(if(config.enable_programmer, do: programmer, else: %{}))
      |> Utils.deep_merge(highlight_data)

    scale_factor =
      if config.blackout do
        0
      else
        config.main_master / 255
      end

    merged_control_data_after_main_master_and_blackout =
      scale_dimmers(merged_control_data, scale_factor)

    fixtures = Map.values(fixtures_map)
    fixtures_for_universe = Enum.filter(fixtures, &(&1.universe == universe_number))

    # calculate list of maps, one for each fixtures
    all_channels =
      Enum.map(fixtures_for_universe, fn fixture ->
        fixture_type = Map.get(fixture_types_map, fixture.fixture_type_id)

        fixture_attribute_values =
          Map.get(merged_control_data_after_main_master_and_blackout, fixture.id)

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
    |> Enum.filter(&(&1.state.master > 0 or Access.get(&1.state, :flash)))
    |> Enum.map(&compute_scene_values/1)
    |> Enum.reduce(%{}, &htp_fixture_merge/2)
  end

  defp compute_scene_values(%Scene{fixtures: fixture_map, state: state}) do
    scene_master =
      max(
        state.master,
        if Access.get(state, :flash) do
          255
        else
          0
        end
      )

    scaled_by_scene_master =
      Enum.into(fixture_map, %{}, fn {guid, attributes_map} ->
        updated =
          attributes_map
          |> Enum.map(fn {key, value} -> {key, value * scene_master / 255} end)
          |> Enum.into(%{})

        {guid, updated}
      end)

    scaled_by_scene_master
  end

  def scale_dimmers(fixtures, factor) do
    for {fixture_id, attribute_map} <- fixtures, into: %{} do
      new_attribute_map =
        case attribute_map do
          %{"dimmer" => dimmer} when is_number(dimmer) ->
            Map.put(attribute_map, "dimmer", dimmer * factor)

          _ ->
            attribute_map
        end

      {fixture_id, new_attribute_map}
    end
  end

  defp htp_fixture_merge(map_1, map_2) do
    Map.merge(map_1, map_2, fn _key, v1, v2 -> htp_merge(v1, v2) end)
  end

  defp htp_merge(map_1, map_2) do
    Map.merge(map_1, map_2, fn _key, v1, v2 -> max(v1, v2) end)
  end

  defp get_highlight_data(users) do
    users
    |> Enum.filter(& &1.highlight)
    |> Enum.reduce(%{}, fn user, acc ->
      fixture_ids =
        case user.primary_selected_fixture_id do
          nil -> user.selected_fixture_ids
          id -> [id]
        end

      Enum.reduce(fixture_ids, acc, fn fixture_id, acc2 ->
        Map.update(acc2, fixture_id, %{"dimmer" => 255}, fn attrs ->
          Map.put(attrs, "dimmer", 255)
        end)
      end)
    end)
  end
end
