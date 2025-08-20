defmodule LiveLightingControl.StateManagerJsonDecoder do
  alias LiveLightingControl.Models.State
  alias LiveLightingControl.Models.Scene
  alias LiveLightingControl.Models.Cue
  alias LiveLightingControl.Models.ExecutorPage
  alias LiveLightingControl.Models.Executor
  alias LiveLightingControl.Models.Fixture
  alias LiveLightingControl.Models.FixtureGroup
  alias LiveLightingControl.Models.FixtureType
  alias LiveLightingControl.Models.FixtureTypeChannel
  alias LiveLightingControl.Models.Layout
  alias LiveLightingControl.Models.Scene
  alias LiveLightingControl.Models.View
  alias LiveLightingControl.Models.Card
  alias LiveLightingControl.Models.User
  alias LiveLightingControl.Models.ActiveEntity
  alias LiveLightingControl.Models.Config

  def decode_json(json) do
    case Jason.decode(json, keys: :atoms) do
      {:ok, map} ->
        # try do
          {:ok, %State{
            active: Enum.map(map[:active], &decode_active_entity/1),
            config: struct(Config, map[:config]),
            programmer: map[:programmer],
            scenes: Enum.map(map[:scenes], &decode_scene/1),
            layouts: Enum.map(map[:layouts], &struct(Layout, &1)),
            fixtures: Enum.map(map[:fixtures], &struct(Fixture, &1)),
            fixture_types: Enum.map(map[:fixture_types], &decode_fixture_type/1),
            fixture_groups: Enum.map(map[:fixture_groups], &struct(FixtureGroup, &1)),
            executor_pages: Enum.map(map[:executor_pages], &decode_executor_page/1),
            views: Enum.map(map[:views], &decode_view/1),
            users: Enum.map(map[:users], &struct(User, &1)),
            command_history: map[:command_history]
          }}
        # rescue
        #   e -> {:error, {:struct_build_failed, e}}
        # end

      {:error, reason} ->
        {:error, {:invalid_json, reason}}
    end
  end

  defp decode_scene(scene_map) do
    %Scene{
      id: scene_map[:id],
      label: scene_map[:label],
      state: scene_map[:state],
      cues: Enum.map(scene_map[:cues], &struct(Cue, &1))
    }
  end

  defp decode_fixture_type(fixture_type_map) do
    %FixtureType{
      id: fixture_type_map[:id],
      label: fixture_type_map[:label],
      channels: Enum.map(fixture_type_map[:channels], &struct(FixtureTypeChannel, &1))
    }
  end

  defp decode_executor_page(executor_page_map) do
    %ExecutorPage{
      id: executor_page_map[:id],
      label: executor_page_map[:label],
      executors:
        Enum.map(executor_page_map[:executors], fn row ->
          Enum.map(row, &decode_executor/1)
        end),
      executor_buttons: executor_page_map[:executor_buttons]
    }
  end

  defp decode_view(view_map) do
    %View{
      id: view_map[:id],
      label: view_map[:label],
      cards: Enum.map(view_map[:cards], &decode_card/1)
    }
  end

  defp decode_card(attrs) do
    attrs
    |> Map.update(:type, nil, &String.to_existing_atom/1)
    |> then(&struct(Card, &1))
  end

  defp decode_active_entity(attrs) do
    attrs
    |> Map.update(:type, nil, &String.to_existing_atom/1)
    |> then(&struct(ActiveEntity, &1))
  end

  defp decode_executor(attrs) do
    attrs
    |> Map.update(:type, nil, &String.to_existing_atom/1)
    |> Map.update(:button_type, nil, &String.to_existing_atom/1)
    |> then(&struct(Executor, &1))
  end
end
