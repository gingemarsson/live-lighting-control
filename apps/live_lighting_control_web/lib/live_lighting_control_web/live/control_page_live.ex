defmodule LiveLightingControlWeb.ControlPageLive do
  use LiveLightingControlWeb, :live_view
  require UUID
  alias LiveLightingControl.Scene

  def mount(_params, _session, socket) do
    cards = [
      %{id: UUID.uuid4(), type: :fixtures},
      # %{id: UUID.uuid4(), type: :selected_fixtures},
      %{id: UUID.uuid4(), type: :programmer},
      %{id: UUID.uuid4(), type: :output},
      %{id: UUID.uuid4(), type: :scenes},
    ]

    Phoenix.PubSub.subscribe(LiveLightingControl.PubSub, "scenes")
    Phoenix.PubSub.subscribe(LiveLightingControl.PubSub, "programmer")
    Phoenix.PubSub.subscribe(LiveLightingControl.PubSub, "output")


    {:ok, assign(socket,
      cards: cards,
      fixtures: Map.values(LiveLightingControl.FixtureManager.get_fixtures_map()),
      fixtures_map: LiveLightingControl.FixtureManager.get_fixtures_map(),
      fixture_types_map: LiveLightingControl.FixtureManager.get_fixture_types_map(),
      scenes: LiveLightingControl.SceneManager.get_scenes(),
      programmer: LiveLightingControl.ProgrammerManager.get_programmer(),
      output: %{},
      selected_fixture_ids: []
    )}
  end

  # Subscriptions from other parts of application

  def handle_info({:scene_updated, _scene}, socket) do
    # Always update all scenes
    {:noreply, assign(socket, :scenes, LiveLightingControl.SceneManager.get_scenes())}
  end

  def handle_info({:programmer_updated, updated_programmer}, socket) do
    {:noreply, assign(socket, :programmer, updated_programmer)}
  end

  def handle_info({:output_update, output}, socket) do
    {:noreply, assign(socket, :output, output)}
  end

  # Page events

  def handle_event("toggle_select_fixture", %{"fixture-id" => fixture_id}, socket) do
    selected_fixture_ids = socket.assigns.selected_fixture_ids

    updated_fixture_ids =
      if fixture_id in selected_fixture_ids do
        List.delete(selected_fixture_ids, fixture_id)
      else
        selected_fixture_ids ++ [fixture_id]
      end

    {:noreply, assign(socket, :selected_fixture_ids, updated_fixture_ids)}
  end

  def handle_event("slider_changed", %{"value" => master_value, "sliderId" => scene_id, "sliderType" => "scene"}, socket) do
    LiveLightingControl.SceneManager.update_scene(%{id: scene_id, state: %{master: master_value}})

    {:noreply, socket}
  end

  def handle_event("slider_changed", %{"value" => value, "sliderId" => attribute, "sliderType" => "programmer"}, socket) do
    LiveLightingControl.ProgrammerManager.update_programmer(%{fixture_ids: socket.assigns.selected_fixture_ids, attribute: attribute, value: round(value * 2.55)})

    {:noreply, socket}
  end

  def handle_event("clear-programmer", _data, socket) do
    LiveLightingControl.ProgrammerManager.clear_programmer()

    {:noreply, socket}
  end

  def handle_event("save-programmer", _data, socket) do
    new_scene = %Scene{id: UUID.uuid4(), label: "New scene", fixtures: socket.assigns.programmer, state: %{master: 100}}
    LiveLightingControl.SceneManager.update_scene(new_scene)

    {:noreply, socket}
  end


  def render(assigns) do
    ~H"""
    <div class="flex-grow w-full max-w-[1920px] m-auto flex flex-col gap-4 p-4">
      <%= for card <- @cards do %>
        <div class={"bg-neutral-800 rounded-lg shadow-md"}>
          <%= case card.type do %>
            <% :fixtures -> %>
              <.live_component module={LiveLightingControlWeb.FixturesLibraryCardComponent} id={card.id} fixtures={@fixtures} selected_fixture_ids={@selected_fixture_ids} />
            <% :scenes -> %>
              <.live_component module={LiveLightingControlWeb.ScenesLibraryCardComponent} id={card.id} scenes={@scenes} />
            <% :output -> %>
              <.live_component module={LiveLightingControlWeb.OutputCardComponent} id={card.id} output={@output} selected_fixture_ids={@selected_fixture_ids} fixtures={@fixtures_map} fixture_types={@fixture_types_map}/>
            <% :selected_fixtures-> %>
            <.live_component module={LiveLightingControlWeb.SelectedFixturesCardComponent} id={card.id} fixtures={@fixtures} selected_fixture_ids={@selected_fixture_ids} />
            <% :programmer-> %>
            <.live_component module={LiveLightingControlWeb.ProgrammerCardComponent} id={card.id} programmer={@programmer} fixtures={@fixtures} fixture_types={Map.values(@fixture_types_map)} selected_fixture_ids={@selected_fixture_ids} />
          <% end %>
        </div>
      <% end %>
    </div>
    <div class="col-span-1 col-span-2 col-span-3 col-span-4" />
    """
  end
end
