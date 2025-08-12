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
        LiveLightingControl.StateManager.execute_command(:flash_on, %{scene_id: entity_id})

      {%{type: :scene, entity_id: entity_id, button_type: :flash}, :button_up} ->
        LiveLightingControl.StateManager.execute_command(:flash_off, %{scene_id: entity_id})

      {%{type: :scene, entity_id: entity_id, button_type: command}, :button_down} ->
        LiveLightingControl.StateManager.execute_command(command, %{scene_id: entity_id})

      {_, _} ->
        nil
    end

    LiveLightingControl.StateManager.update_executor(executor_id, fn x ->
      Utils.deep_merge(x, %{state: %{active: action == :button_down}})
    end)
  end
end
