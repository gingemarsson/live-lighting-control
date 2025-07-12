defmodule LiveLightingControl.Utils do
  def get_selected_fixtures(fixtures, selected_fixture_ids) do
    find_fixture_by_id = &Enum.find(fixtures, fn fixture -> fixture.id == &1 end)
    Enum.map(selected_fixture_ids, find_fixture_by_id)
  end
end
