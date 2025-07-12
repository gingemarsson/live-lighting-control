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
      %Scene{id: UUID.uuid4(), label: "Moody", description: "A moody lighting scene.", fixtures: [%{"1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a" => %{"dimmer" => 20}}], state: %{master: 90}},
      %Scene{id: UUID.uuid4(), label: "Party", description: "A vibrant party lighting scene.", fixtures: [%{"83e98c74-c272-42db-91b0-d4ce6adb4c90" => %{"dimmer" => 255}}], state: %{master: 50}},
      %Scene{id: UUID.uuid4(), label: "Relax", description: "A relaxing lighting scene.", fixtures: [%{"15867280-3f56-4824-a56c-5059b16b183b" => %{"dimmer" => 50}}], state: %{master: 50}},
      %Scene{id: UUID.uuid4(), label: "All lights", description: "A relaxing lighting scene.", fixtures: [
        %{"1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a" => %{"dimmer" => 255}},
        %{"83e98c74-c272-42db-91b0-d4ce6adb4c90" => %{"dimmer" => 255}},
        %{"15867280-3f56-4824-a56c-5059b16b183b" => %{"dimmer" => 255}}
        ], state: %{master: 50}}
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
