defmodule LiveLightingControl.TextCommandHandler do
  def execute_text_command(text_command, user_id) do
    String.split(text_command)
    |> handle_command(%{user_id: user_id})
  end

  defp handle_command(["blackout"], params) do LiveLightingControl.StateManager.execute_command(:toggle_blackout, params) end
  defp handle_command(["blind"], params) do LiveLightingControl.StateManager.execute_command(:toggle_programmer, params) end
  defp handle_command(["toggle-sacn-output"], params) do LiveLightingControl.StateManager.execute_command(:toggle_sacn_output, params) end

  defp handle_command(["page-up"], params) do LiveLightingControl.StateManager.execute_command(:page_up, params) end
  defp handle_command(["page-down"], params) do LiveLightingControl.StateManager.execute_command(:page_down, params) end

  defp handle_command(["highlight"], params) do LiveLightingControl.StateManager.execute_command(:highlight, params) end
  defp handle_command(["next"], params) do LiveLightingControl.StateManager.execute_command(:next_primary_selection, params) end
  defp handle_command(["prev"], params) do LiveLightingControl.StateManager.execute_command(:previous_primary_selection, params) end
  defp handle_command(["set"], params) do LiveLightingControl.StateManager.execute_command(:reset_primary_selection, params) end

  defp handle_command(["select", fixture_id], params) do LiveLightingControl.StateManager.execute_command(:toggle_select_fixture, Map.put(params, :fixture_id, fixture_id)) end
  defp handle_command(["select-group", fixture_group_id], params) do LiveLightingControl.StateManager.execute_command(:toggle_select_fixture_group, Map.put(params, :fixture_group_id, fixture_group_id)) end

  defp handle_command(_parts, _params) do nil end

end
