defmodule LiveLightingControl.Utils do
  def get_selected_fixtures(fixtures, selected_fixture_ids) do
    find_fixture_by_id = &Enum.find(fixtures, fn fixture -> fixture.id == &1 end)
    Enum.map(selected_fixture_ids, find_fixture_by_id)
  end

  def is_fixtures_selected?(fixture_ids, selected_fixture_ids) do
    cond do
      Enum.all?(fixture_ids, fn x -> x in selected_fixture_ids end) ->
        :all

      Enum.any?(fixture_ids, fn x -> x in selected_fixture_ids end) ->
        :some

      true ->
        false
    end
  end
end
