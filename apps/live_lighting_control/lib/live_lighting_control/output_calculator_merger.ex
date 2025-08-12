defmodule LiveLightingControl.OutputCalculatorMerger do
  alias LiveLightingControl.Utils

  @doc """
  Merges scenes into a final fixture → attribute → %{value, contributors} map
  based on cue ordering and fade calculations.

  `active` is a list if ActiveEntity structs.
  `scenes` is a list of Scene structs.
  `current_time` is the timestamp (same units as triggered_time/fade_completed_time).
  """
  def merge_scenes(active, scenes, current_time) do
    result =
      active
      |> collect_cues(scenes, current_time)
      |> sort_cues_by_trigger_time()
      |> group_by_fixture_and_attribute()
      |> merge_attributes()

    result
  end

  # Step 1
  defp collect_cues(active, scenes, current_time) do
    scenes_map = Map.new(scenes, &{&1.id, &1})
    cues_map = Enum.flat_map(scenes, & &1.cues) |> Map.new(&{&1.id, &1})

    Enum.map(active, fn active_entity ->
      scene = Map.get(scenes_map, active_entity.scene_id)
      cue = Map.get(cues_map, active_entity.cue_id)

      %{
        active_id: active_entity.id,
        cue: cue,
        scene_id: scene.id,
        scene_master: scene_master(scene),
        fade_factor: Utils.get_fade_factor(active_entity, current_time),
        fade_in_triggered_time: active_entity.fade_in_triggered_time
      }
    end)
  end

  defp scene_master(%{state: state}) do
    max(
      state.master,
      if Access.get(state, :flash) do
        255
      else
        0
      end
    )
  end

  # Step 2
  defp sort_cues_by_trigger_time(cue_wrappers) do
    Enum.sort_by(cue_wrappers, fn cue_wrapper -> cue_wrapper.fade_in_triggered_time end, :desc)
  end

  # Step 3
  defp group_by_fixture_and_attribute(cue_wrappers) do
    cue_wrappers
    |> Enum.reduce(%{}, fn cue_wrapper, acc ->
      Enum.reduce(cue_wrapper.cue.fixture_attribute_map, acc, fn {fixture_id, attr_map}, acc ->
        Enum.reduce(attr_map, acc, fn {attr_id, value}, acc ->
          Map.update(
            acc,
            fixture_id,
            %{
              attr_id => [
                %{
                  cue: cue_wrapper.cue,
                  scene_id: cue_wrapper.scene_id,
                  value: value * cue_wrapper.scene_master / 255,
                  fade_factor: cue_wrapper.fade_factor
                }
              ]
            },
            fn existing_fixture_map ->
              Map.update(
                existing_fixture_map,
                attr_id,
                [
                  %{
                    cue: cue_wrapper.cue,
                    scene_id: cue_wrapper.scene_id,
                    value: value * cue_wrapper.scene_master / 255,
                    fade_factor: cue_wrapper.fade_factor
                  }
                ],
                fn existing_attr_list ->
                  existing_attr_list ++
                    [
                      %{
                        cue: cue_wrapper.cue,
                        scene_id: cue_wrapper.scene_id,
                        value: value * cue_wrapper.scene_master / 255,
                        fade_factor: cue_wrapper.fade_factor
                      }
                    ]
                end
              )
            end
          )
        end)
      end)
    end)
    |> Enum.into(%{}, fn {fixture_id, attr_map} ->
      attr_map_sorted =
        Enum.into(attr_map, %{}, fn {attr_id, cue_list} ->
          {attr_id, cue_list}
        end)

      {fixture_id, attr_map_sorted}
    end)
  end

  # Step 4
  defp merge_attributes(fixtures_map) do
    Enum.into(fixtures_map, %{}, fn {fixture_id, attr_map} ->
      merged_attrs =
        Enum.into(attr_map, %{}, fn {attr_id, cue_list} ->
          {value, contributors} = weighted_merge(cue_list)
          {attr_id, %{value: value, contributors: contributors, type: :scene}}
        end)

      {fixture_id, merged_attrs}
    end)
  end

  defp weighted_merge(cue_list) do
    {final_value, contributors, _remaining} =
      Enum.reduce(cue_list, {0.0, [], 1.0}, fn %{
                                                 cue: cue,
                                                 scene_id: scene_id,
                                                 value: value,
                                                 fade_factor: factor
                                               },
                                               {acc_val, acc_contribs, remaining} ->
        weight = remaining * factor
        new_value = acc_val + value * weight

        {
          new_value,
          acc_contribs ++
            [
              %{
                scene_id: scene_id,
                cue_id: cue.id,
                value: value,
                weight: weight
              }
            ],
          remaining - weight
        }
      end)

    # If remaining > 0, fill with 0 (no contribution)
    {round(final_value), contributors}
  end
end
