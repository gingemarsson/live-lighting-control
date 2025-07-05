defmodule LiveLightingControlWeb.ControlPageLive do
  use LiveLightingControlWeb, :live_view
  require UUID

  def mount(_params, _session, socket) do
    cards = [
      %{id: UUID.uuid4(), type: :fixtures, cols: 2},
      %{id: UUID.uuid4(), type: :scenes, cols: 1},
      %{id: UUID.uuid4(), type: :selected_fixtures, cols: 1},
    ]

    fixtures = [
      %{id: UUID.uuid4(), label: "Axcore 1", dmx_address: 1, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]},
      %{id: UUID.uuid4(), label: "Axcore 2", dmx_address: 2, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]},
      %{id: UUID.uuid4(), label: "Axcore 3", dmx_address: 3, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]},
      %{id: UUID.uuid4(), label: "Axcore 4", dmx_address: 4, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]},
      %{id: UUID.uuid4(), label: "Axcore 5", dmx_address: 5, channels: [%{name: "Intensity", dmx_address: 1, type: :intensity}]}
    ]

    scenes = [
      %{id: UUID.uuid4(), label: "Moody", description: "A moody lighting scene.", scene: %{fixture_id: UUID.uuid4(), values: %{"Intensity" => 20}}},
      %{id: UUID.uuid4(), label: "Party", description: "A vibrant party lighting scene.", scene: %{fixture_id: UUID.uuid4(), values: %{"Intensity" => 100}}},
      %{id: UUID.uuid4(), label: "Relax", description: "A relaxing lighting scene.", scene: %{fixture_id: UUID.uuid4(), values: %{"Intensity" => 50}}}
    ]

    {:ok, assign(socket,
      cards: cards,
      fixtures: fixtures,
      scenes: scenes,
      selected_fixture_ids: []
    )}
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
    """
  end
end
