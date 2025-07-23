defmodule LiveLightingControl.SceneManager do
  use GenServer

  alias LiveLightingControl.Scene
  alias LiveLightingControl.Utils

  @typedoc "Scene ID, expected to be a UUID string"
  @type scene_id :: String.t()

  @typedoc "Map of scenes keyed by their ID"
  @type scene_map :: %{scene_id() => Scene.t()}

  @typedoc "Partial scene updates. Must include at least an `id` field."
  # Ideally, you'd define a more specific type in Scene module
  @type partial_scene :: map()

  @typedoc "GenServer state"
  @type state :: scene_map()

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec get_scenes() :: [Scene.t()]
  def get_scenes do
    GenServer.call(__MODULE__, :get_scenes)
  end

  @spec update_scene(partial_scene()) :: :ok
  def update_scene(partial_scene) do
    GenServer.cast(__MODULE__, {:update_partial_scene, partial_scene})
  end

  # Server Callbacks

  @impl true
  @spec init(any()) :: {:ok, state()}
  def init(_args) do
    scenes = [
      %Scene{
        id: "69ac89df-fdaf-481d-9788-d522a159a465",
        label: "Moody",
        description: "A moody lighting scene.",
        fixtures: %{"1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a" => %{"dimmer" => 255}},
        state: %{master: 90}
      },
      %Scene{
        id: "4b17863d-99f3-4ce9-bacb-e9e3e67b9b31",
        label: "Party",
        description: "A vibrant party lighting scene.",
        fixtures: %{"83e98c74-c272-42db-91b0-d4ce6adb4c90" => %{"dimmer" => 255}},
        state: %{master: 50}
      },
      %Scene{
        id: "7b7f7fc7-69c0-4eb2-86a5-22fa8e2d1144",
        label: "Relax",
        description: "A relaxing lighting scene.",
        fixtures: %{"15867280-3f56-4824-a56c-5059b16b183b" => %{"dimmer" => 255}},
        state: %{master: 50}
      },
      %Scene{
        id: "00d0b87a-c9f7-4727-84a7-841f15c9fcae",
        label: "All lights",
        description: "A relaxing lighting scene.",
        fixtures: %{
          "1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a" => %{"dimmer" => 255},
          "83e98c74-c272-42db-91b0-d4ce6adb4c90" => %{"dimmer" => 255},
          "15867280-3f56-4824-a56c-5059b16b183b" => %{"dimmer" => 255}
        },
        state: %{master: 50}
      }
    ]

    {:ok, Map.new(scenes, &{&1.id, &1})}
  end

  @impl true
  @spec handle_call(:get_scenes, GenServer.from(), state()) :: {:reply, [Scene.t()], state()}
  def handle_call(:get_scenes, _from, scenes) do
    {:reply, scenes, scenes}
  end

  @impl true
  def handle_cast({:update_partial_scene, partial_scene}, scenes) do
    id = partial_scene.id

    existing = Map.get(scenes, id, %Scene{id: id})
    updated = Utils.deep_merge(existing, partial_scene)

    new_scenes = Map.put(scenes, updated.id, updated)

    notify_scene_updated(updated)

    {:noreply, new_scenes}
  end

  defp notify_scene_updated(scene) do
    Phoenix.PubSub.broadcast(LiveLightingControl.PubSub, "scenes", {:scene_updated, scene})
  end
end
