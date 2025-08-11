defmodule LiveLightingControl.StateManagerCommandHandler do
  alias LiveLightingControl.Utils

  # Toggle config
  def execute_command(:toggle_sacn_output, _parameters, state) do update_config(:enable_sacn_output, &(!&1), state) end
  def execute_command(:toggle_programmer, _parameters, state) do update_config(:enable_programmer, &(!&1), state) end
  def execute_command(:toggle_blackout, _parameters, state) do update_config(:blackout, &(!&1), state) end

  # User parameters
  def execute_command(:page_up, %{user_id: user_id}, state) do
    total_pages = length(state.executor_pages)
    update_element_in_list_by_id(:users, user_id, fn user -> Map.update!(user, :current_page_index, &rem(&1 + 1, total_pages)) end, state)
  end

  def execute_command(:page_down, %{user_id: user_id}, state) do
    total_pages = length(state.executor_pages)
    update_element_in_list_by_id(:users, user_id, fn user -> Map.update!(user, :current_page_index, &rem(&1 - 1, total_pages)) end, state)
  end

  def execute_command(:highlight, %{user_id: user_id}, state) do
    update_element_in_list_by_id(:users, user_id, fn user -> Map.update!(user, :highlight, &(!&1)) end, state)
  end

  # Selection
  def execute_command(:reset_primary_selection, %{user_id: user_id}, state) do
    update_element_in_list_by_id(:users, user_id, fn user -> Map.put(user, :primary_selected_fixture_id, nil) end, state)
  end

  def execute_command(:next_primary_selection, %{user_id: user_id}, state) do
    update_element_in_list_by_id(:users, user_id, fn user ->
      ids = user.selected_fixture_ids

      next_id =
        case Enum.find_index(ids, &(&1 == user.primary_selected_fixture_id)) do
          nil -> List.first(ids)
          idx -> Enum.at(ids, rem(idx + 1, length(ids)))
        end

      Map.put(user, :primary_selected_fixture_id, next_id)
    end, state)
  end

  def execute_command(:previous_primary_selection, %{user_id: user_id}, state) do
    update_element_in_list_by_id(:users, user_id, fn user ->
      ids = user.selected_fixture_ids

      next_id =
        case Enum.find_index(ids, &(&1 == user.primary_selected_fixture_id)) do
          nil -> List.first(ids)
          idx -> Enum.at(ids, rem(idx - 1, length(ids)))
        end

      Map.put(user, :primary_selected_fixture_id, next_id)
    end, state)
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

end
