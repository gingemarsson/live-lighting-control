defmodule LiveLightingControl.SceneManager do
  use GenServer

  alias LiveLightingControl.Scene

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_scenes do
    GenServer.call(__MODULE__, :get_scenes)
  end

  def update_scene(partial_scene) do
    GenServer.cast(__MODULE__, {:update_partial_scene, partial_scene})
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    scenes = [
      %Scene{id: UUID.uuid4(), label: "Moody", description: "A moody lighting scene.", scene: %{fixture_id: UUID.uuid4(), values: %{"Intensity" => 20}}, state: %{master: 90}},
      %Scene{id: UUID.uuid4(), label: "Party", description: "A vibrant party lighting scene.", scene: %{fixture_id: UUID.uuid4(), values: %{"Intensity" => 100}}, state: %{master: 50}},
      %Scene{id: UUID.uuid4(), label: "Relax", description: "A relaxing lighting scene.", scene: %{fixture_id: UUID.uuid4(), values: %{"Intensity" => 50}}, state: %{master: 50}}
    ]

    {:ok, Map.new(scenes, &{&1.id, &1})}
  end

  @impl true
  def handle_call(:get_scenes, _from, scenes) do
    {:reply, Map.values(scenes), scenes}
  end

  @impl true
  def handle_cast({:update_partial_scene, partial_scene}, scenes) do
    id = partial_scene.id

    existing = Map.get(scenes, id, %Scene{id: id})
    updated = Map.merge(existing, partial_scene)

    new_scenes = Map.put(scenes, updated.id, updated)

    notify_scene_updated(updated)

    {:noreply, new_scenes}
  end

  defp notify_scene_updated(scene) do
    Phoenix.PubSub.broadcast(LiveLightingControl.PubSub, "scenes", {:scene_updated, scene})
  end
end
