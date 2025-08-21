defmodule LiveLightingControl.StateManagerCommandHandler do
  alias LiveLightingControl.Utils

  # Toggle config
  def execute_command(:toggle_sacn_output, _parameters, state) do
    update_config(:enable_sacn_output, &(!&1), state)
  end

  def execute_command(:toggle_programmer, _parameters, state) do
    update_config(:enable_programmer, &(!&1), state)
  end

  def execute_command(:toggle_blackout, _parameters, state) do
    update_config(:blackout, &(!&1), state)
  end

  # User parameters
  def execute_command(:page_up, %{user_id: user_id}, state) do
    total_pages = length(state.executor_pages)

    update_element_in_list_by_id(
      :users,
      user_id,
      fn user -> Map.update!(user, :current_page_index, &rem(&1 + 1, total_pages)) end,
      state
    )
  end

  def execute_command(:page_down, %{user_id: user_id}, state) do
    total_pages = length(state.executor_pages)

    update_element_in_list_by_id(
      :users,
      user_id,
      fn user -> Map.update!(user, :current_page_index, &rem(&1 - 1, total_pages)) end,
      state
    )
  end

  def execute_command(:highlight, %{user_id: user_id}, state) do
    update_element_in_list_by_id(
      :users,
      user_id,
      fn user -> Map.update!(user, :highlight, &(!&1)) end,
      state
    )
  end

  # Selection
  def execute_command(:toggle_select_fixture, %{user_id: user_id, fixture_id: fixture_id}, state) do
    update_element_in_list_by_id(
      :users,
      user_id,
      fn user ->
        Map.merge(user, %{
          selected_fixture_ids: toggle_select_fixtures([fixture_id], user.selected_fixture_ids),
          primary_selected_fixture_id: nil
        })
      end,
      state
    )
  end

  def execute_command(
        :toggle_select_fixture_group,
        %{user_id: user_id, fixture_group_id: fixture_group_id},
        state
      ) do
    fixture_group_fixtures =
      Utils.find_in_list_by_id(state.fixture_groups, fixture_group_id).fixture_ids

    update_element_in_list_by_id(
      :users,
      user_id,
      fn user ->
        Map.merge(user, %{
          selected_fixture_ids:
            toggle_select_fixtures(fixture_group_fixtures, user.selected_fixture_ids),
          primary_selected_fixture_id: nil
        })
      end,
      state
    )
  end

  def execute_command(:reset_primary_selection, %{user_id: user_id}, state) do
    update_element_in_list_by_id(
      :users,
      user_id,
      fn user -> Map.put(user, :primary_selected_fixture_id, nil) end,
      state
    )
  end

  def execute_command(:next_primary_selection, %{user_id: user_id}, state) do
    update_element_in_list_by_id(
      :users,
      user_id,
      fn user ->
        ids = user.selected_fixture_ids

        next_id =
          case Enum.find_index(ids, &(&1 == user.primary_selected_fixture_id)) do
            nil -> List.first(ids)
            idx -> Enum.at(ids, rem(idx + 1, length(ids)))
          end

        Map.put(user, :primary_selected_fixture_id, next_id)
      end,
      state
    )
  end

  def execute_command(:previous_primary_selection, %{user_id: user_id}, state) do
    update_element_in_list_by_id(
      :users,
      user_id,
      fn user ->
        ids = user.selected_fixture_ids

        next_id =
          case Enum.find_index(ids, &(&1 == user.primary_selected_fixture_id)) do
            nil -> List.first(ids)
            idx -> Enum.at(ids, rem(idx - 1, length(ids)))
          end

        Map.put(user, :primary_selected_fixture_id, next_id)
      end,
      state
    )
  end

  # Scene actions
  def execute_command(:flash_on, %{scene_id: scene_id}, state) do
    update_element_in_list_by_id(
      :scenes,
      scene_id,
      fn scene -> %{scene | state: Map.put(scene.state, :flash, true)} end,
      state
    )
  end

  def execute_command(:flash_off, %{scene_id: scene_id}, state) do
    update_element_in_list_by_id(
      :scenes,
      scene_id,
      fn scene -> %{scene | state: Map.put(scene.state, :flash, false)} end,
      state
    )
  end

  def execute_command(:go, %{scene_id: scene_id}, state) do
    activate_current_cue_of_scene(state, scene_id)
  end

  def execute_command(:next, %{scene_id: scene_id}, state) do
    update_element_in_list_by_id(
      :scenes,
      scene_id,
      fn scene ->
        %{
          scene
          | state: %{scene.state | cue_index: rem(scene.state.cue_index + 1, length(scene.cues))}
        }
      end,
      state
    )
    |> activate_current_cue_of_scene(scene_id)
  end

  def execute_command(:previous, %{scene_id: scene_id}, state) do
    update_element_in_list_by_id(
      :scenes,
      scene_id,
      fn scene ->
        %{
          scene
          | state: %{scene.state | cue_index: rem(scene.state.cue_index - 1, length(scene.cues))}
        }
      end,
      state
    )
    |> activate_current_cue_of_scene(scene_id)
  end

  def execute_command(:off, %{scene_id: scene_id}, state) do
    %{start_time: start_time, end_time: end_time} = get_times(5000)

    update_active_by_scene_id(
      scene_id,
      nil,
      nil,
      fn active_entity ->
        Map.merge(active_entity, %{
          fade_out_triggered_time: start_time,
          fade_out_completed_time: end_time
        })
      end,
      state
    )
  end

  # Other
  def execute_command(:main_master, %{value: value}, state) do
    update_config(:main_master, fn _ -> value end, state)
  end

  # Helpers
  defp update_config(config_key, update_fn, state) do
    %{state | config: Map.update!(state.config, config_key, update_fn)}
  end

  defp update_element_in_list_by_id(list_key, element_id, update_fn, state) do
    updated_list =
      state
      |> Map.fetch!(list_key)
      |> Utils.update_element_in_list_by_id(element_id, update_fn)

    %{state | list_key => updated_list}
  end

  def toggle_select_fixtures(fixture_ids, selected_fixture_ids) do
    if Utils.is_fixtures_selected?(fixture_ids, selected_fixture_ids) == :all do
      Enum.reject(selected_fixture_ids, &(&1 in fixture_ids))
    else
      selected_fixture_ids ++ fixture_ids
    end
  end

  defp get_active_entity_from_scene_and_cue(scene_id, cue_id) do
    %{start_time: start_time, end_time: end_time} = get_times(2000)

    element = %LiveLightingControl.Models.ActiveEntity{
      id: UUID.uuid4(),
      type: :scene_cue,
      scene_id: scene_id,
      cue_id: cue_id,
      fade_in_triggered_time: start_time,
      fade_in_completed_time: end_time,
      fade_out_triggered_time: nil,
      fade_out_completed_time: nil
    }

    element
  end

  defp get_times(fade_time) do
    current_time = System.os_time(:millisecond)
    %{start_time: current_time, end_time: current_time + fade_time}
  end

  defp update_active_by_scene_id(scene_id, cue_ids, except_cue_ids, update_fn, state) do
    %{
      state
      | active:
          Enum.map(state.active, fn
            %{scene_id: ^scene_id, cue_id: cue_id} = exec ->
              cond do
                cue_id in (except_cue_ids || []) ->
                  exec

                cue_ids != nil and cue_ids != [] and cue_id not in cue_ids ->
                  exec

                true ->
                  update_fn.(exec)
              end

            exec ->
              exec
          end)
    }
  end

  def activate_current_cue_of_scene(state, scene_id) do
    active_entity =
      state.scenes
      |> Utils.find_in_list_by_id(scene_id)
      |> then(fn scene ->
        cue = Enum.at(scene.cues, scene.state.cue_index)
        get_active_entity_from_scene_and_cue(scene.id, cue.id)
      end)

    %{state | active: [active_entity | state.active]}
  end
end
