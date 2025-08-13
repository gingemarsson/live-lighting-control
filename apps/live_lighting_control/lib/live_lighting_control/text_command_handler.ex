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

  def get_text_command(command, parameters) do
    get_text_command_text(command, parameters)
  end

  defp get_text_command_text(:toggle_blackout, _parameters) do "blackout" end
  defp get_text_command_text(:toggle_programmer, _parameters) do "blind" end
  defp get_text_command_text(:toggle_sacn_output, _parameters) do "toggle-sacn-output" end

  defp get_text_command_text(:page_up, _parameters) do "page-up" end
  defp get_text_command_text(:page_down, _parameters) do "page-down" end

  defp get_text_command_text(:highlight, _parameters) do "highlight" end
  defp get_text_command_text(:next_primary_selection, _parameters) do "next" end
  defp get_text_command_text(:previous_primary_selection, _parameters) do "prev" end
  defp get_text_command_text(:reset_primary_selection, _parameters) do "set" end

  defp get_text_command_text(:toggle_select_fixture, %{fixture_id: fixture_id}) do "select " <> fixture_id end
  defp get_text_command_text(:toggle_select_fixture_group, %{fixture_group_id: fixture_group_id}) do "select-group " <> fixture_group_id end

  defp get_text_command_text(atom, _param) do Atom.to_string(atom) end
end
