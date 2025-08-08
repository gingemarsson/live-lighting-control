defmodule LiveLightingControl.ExecutorManager do
  alias LiveLightingControl.Models.Executor
  alias LiveLightingControl.Utils

  @impl true
  @impl true
  def handle_executor_slider(executor_id, new_value, executor_pages) do
    executors = Enum.flat_map(executor_pages, fn page -> List.flatten(page.executors) end)
    executor = Enum.find(executors, fn %Executor{id: id} -> id == executor_id end)

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

  @impl true
  def handle_executor_action(executor_id, action, executor_pages) do
    executors = Enum.flat_map(executor_pages, fn page -> List.flatten(page.executors) end)
    executor = Enum.find(executors, fn %Executor{id: id} -> id == executor_id end)

    case {executor, action} do
      {nil, _} ->
        nil

      {%{type: :scene, entity_id: entity_id, button_type: :flash}, :button_down} ->
        LiveLightingControl.StateManager.update_scene(%{id: entity_id, state: %{flash: true}})

      {%{type: :scene, entity_id: entity_id, button_type: :flash}, :button_up} ->
        LiveLightingControl.StateManager.update_scene(%{id: entity_id, state: %{flash: false}})

      {_, _} ->
        nil
    end

    LiveLightingControl.StateManager.update_executor(executor_id, fn x ->
      Utils.deep_merge(x, %{state: %{active: action == :button_down}})
    end)
  end
end
