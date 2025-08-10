defmodule LiveLightingControl.ExecutorManager do
  alias LiveLightingControl.Utils

  def handle_executor_slider(executor_id, new_value) do
    state = LiveLightingControl.StateManager.get_state()
    executors = Enum.flat_map(state.executor_pages, fn page -> List.flatten(page.executors) end)
    executor = Utils.find_in_list_by_id(executors, executor_id)

    case executor do
      nil ->
        nil

      %{type: :scene, entity_id: entity_id} ->
        LiveLightingControl.StateManager.update_scene(%{
          id: entity_id,
          state: %{master: new_value}
        })
    end
  end

  def handle_executor_action(executor_id, action) do
    state = LiveLightingControl.StateManager.get_state()
    executors = Enum.flat_map(state.executor_pages, fn page -> List.flatten(page.executors) end)
    executor = Utils.find_in_list_by_id(executors, executor_id)

    case {executor, action} do
      {nil, _} ->
        nil

      {%{type: :scene, entity_id: entity_id, button_type: :flash}, :button_down} ->
        LiveLightingControl.StateManager.update_scene(%{id: entity_id, state: %{flash: true}})

      {%{type: :scene, entity_id: entity_id, button_type: :flash}, :button_up} ->
        LiveLightingControl.StateManager.update_scene(%{id: entity_id, state: %{flash: false}})

      {%{type: :scene, entity_id: entity_id, button_type: :go}, :button_down} ->
        scene = Utils.find_in_list_by_id(state.scenes, entity_id)
        cue_index = scene.state.cue_index
        cue = Enum.at(scene.cues, cue_index)

        add_scene_and_cue_to_active(scene.id, cue.id)

      {%{type: :scene, entity_id: entity_id, button_type: :off}, :button_down} ->
        scene = Utils.find_in_list_by_id(state.scenes, entity_id)
        cue_index = scene.state.cue_index
        cue = Enum.at(scene.cues, cue_index)

        set_off_fade_for_scene_and_cue(scene.id, cue.id)

      {%{type: :scene, entity_id: entity_id, button_type: :next}, :button_down} ->
        scene = Utils.find_in_list_by_id(state.scenes, entity_id)
        updated_cue_index = rem(scene.state.cue_index + 1, length(scene.cues))

        cue = Enum.at(scene.cues, updated_cue_index)

        add_scene_and_cue_to_active(scene.id, cue.id)

        LiveLightingControl.StateManager.update_scene(%{
          id: entity_id,
          state: %{cue_index: updated_cue_index}
        })

      {%{type: :scene, entity_id: entity_id, button_type: :previous}, :button_down} ->
        scene = Utils.find_in_list_by_id(state.scenes, entity_id)
        updated_cue_index = rem(scene.state.cue_index - 1, length(scene.cues))

        cue = Enum.at(scene.cues, updated_cue_index)

        add_scene_and_cue_to_active(scene.id, cue.id)

        LiveLightingControl.StateManager.update_scene(%{
          id: entity_id,
          state: %{cue_index: updated_cue_index}
        })

      {_, _} ->
        nil
    end

    LiveLightingControl.StateManager.update_executor(executor_id, fn x ->
      Utils.deep_merge(x, %{state: %{active: action == :button_down}})
    end)
  end

  defp add_scene_and_cue_to_active(scene_id, cue_id) do
    current_time = System.os_time(:millisecond)
    fade_time = 2000

    element = %LiveLightingControl.Models.ActiveCue{
      id: UUID.uuid4(),
      type: :scene_cue,
      scene_id: scene_id,
      cue_id: cue_id,
      fade_in_triggered_time: current_time,
      fade_in_completed_time: current_time + fade_time,
      fade_out_triggered_time: nil,
      fade_out_completed_time: nil
    }

    LiveLightingControl.StateManager.add_active(element)
  end

  def set_off_fade_for_scene_and_cue(scene_id, cue_id) do
    current_time = System.os_time(:millisecond)
    fade_time = 2000

    fade_out_completed_time = current_time + fade_time

    LiveLightingControl.StateManager.update_active_by_scene_id(scene_id, [cue_id], nil, fn x ->
      cond do
        # Skip update if fade-out already ongoing
        x.fade_out_triggered_time && current_time >= x.fade_out_triggered_time ->
          x

        # Otherwise, start/continue fade-out
        true ->
          Map.merge(x, %{
            fade_out_triggered_time: current_time,
            fade_out_completed_time: fade_out_completed_time
          })
      end
    end)
  end
end
