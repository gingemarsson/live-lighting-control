defmodule LiveLightingControlWeb.ControlPageLive do
  use LiveLightingControlWeb, :live_view
  require UUID

  def mount(_params, _session, socket) do
    cards = [
      %{id: UUID.uuid4(), type: :fixtures, cols: 2},
      %{id: UUID.uuid4(), type: :selected_fixtures, cols: 1},
      %{id: UUID.uuid4(), type: :selected_fixtures, cols: 1},
      %{id: UUID.uuid4(), type: :scenes, cols: 4},
    ]

    fixtures = [
      %{id: UUID.uuid4(), label: "Axcore 1", dmx_address: 1, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]},
      %{id: UUID.uuid4(), label: "Axcore 2", dmx_address: 2, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]},
      %{id: UUID.uuid4(), label: "Axcore 3", dmx_address: 3, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]},
      %{id: UUID.uuid4(), label: "Axcore 4", dmx_address: 4, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]},
      %{id: UUID.uuid4(), label: "Axcore 5", dmx_address: 5, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]}
    ]

    Phoenix.PubSub.subscribe(LiveLightingControl.PubSub, "scenes")

    {:ok, assign(socket,
      cards: cards,
      fixtures: fixtures,
      scenes: LiveLightingControl.SceneManager.get_scenes(),
      selected_fixture_ids: []
    )}
  end

  def handle_info({:scene_updated, _scene}, socket) do
    # Always update all scenes
    {:noreply, assign(socket, :scenes, LiveLightingControl.SceneManager.get_scenes())}
  end

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

  def handle_event("slider_changed", %{"value" => master_value, "sliderId" => scene_id}, socket) do
    LiveLightingControl.SceneManager.update_scene(%{id: scene_id, state: %{master: master_value}})

    {:noreply, socket}
  end


  def render(assigns) do
    ~H"""
    <div class="flex-grow w-full h-full grid grid-cols-2 xl:grid-cols-4 grid-rows-2 gap-4 p-4">
      <%= for card <- @cards do %>
        <div class={"bg-neutral-800 rounded-lg shadow-md col-span-#{card.cols}"}>
          <%= case card.type do %>
            <% :fixtures -> %>
              <.live_component module={LiveLightingControlWeb.FixturesLibraryCardComponent} id={card.id} fixtures={@fixtures} selected_fixture_ids={@selected_fixture_ids} />
            <% :scenes -> %>
              <.live_component module={LiveLightingControlWeb.ScenesLibraryCardComponent} id={card.id} scenes={@scenes} />
            <% :selected_fixtures-> %>
            <.live_component module={LiveLightingControlWeb.SelectedFixturesCardComponent} id={card.id} fixtures={@fixtures} selected_fixture_ids={@selected_fixture_ids} />
          <% end %>
        </div>
      <% end %>
    </div>
    <div class="col-span-1 col-span-2 col-span-3 col-span-4" />
    """
  end
end
