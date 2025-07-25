defmodule LiveLightingControl.Utils do
  def get_selected_fixtures(fixtures, selected_fixture_ids) do
    find_fixture_by_id = &Enum.find(fixtures, fn fixture -> fixture.id == &1 end)
    Enum.map(selected_fixture_ids, find_fixture_by_id)
  end

  def get_executor(row_number, executor_number, current_page) do
    current_page.executors
    |> Enum.at(row_number)
    |> Enum.at(executor_number - 1)
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

  def deep_merge(map1, map2) when is_map(map1) and is_map(map2) do
    Map.merge(map1, map2, fn _key, val1, val2 ->
      deep_merge(val1, val2)
    end)
  end

  def deep_merge(_val1, val2), do: val2

  def get_fixture_border_color(fixture_id, selected_fixture_ids, primary_selected_fixture_id) do
    cond do
      fixture_id == primary_selected_fixture_id ->
        "border-orange-600"

      fixture_id in selected_fixture_ids and primary_selected_fixture_id == nil ->
        "border-orange-600"

      fixture_id in selected_fixture_ids ->
        "border-yellow-800"

      true ->
        "border-neutral-600 hover:border-neutral-400"
    end
  end
end
