defmodule LiveLightingControlWeb.ControlPageLive do
  use LiveLightingControlWeb, :live_view

  def mount(_params, _session, socket) do
    cards = [
      %{type: :control_panel, description: "Manage your lighting settings here.", icon: "fa-solid fa-lightbulb", cols: 2},
      %{type: :configuration, description: "Adjust your configuration settings.", icon: "fa-solid fa-cog", cols: 1},
      %{type: :status, description: "Check the status of your lighting system.", icon: "fa-solid fa-info-circle", cols: 1},
      %{type: :logs, description: "View system logs and activity.", icon: "fa-solid fa-file-alt", cols: 2}
    ]

    fixtures = [
      %{id: 1, label: "Stage Truss Axcore 1", dmx_address: 1, channels: [%{ name: "Intensity", dmx_address: 1, type: :intensity }]},
      %{id: 2, label: "Stage Truss Axcore 2", dmx_address: 2, channels: [%{ name: "Intensity", dmx_address: 1, type: :intensity }]},
      %{id: 3, label: "Stage Truss Axcore 3", dmx_address: 3, channels: [%{ name: "Intensity", dmx_address: 1, type: :intensity }]},
      %{id: 4, label: "Stage Truss Axcore 4", dmx_address: 4, channels: [%{ name: "Intensity", dmx_address: 1, type: :intensity }]},
      %{id: 5, label: "Stage Truss Axcore 5", dmx_address: 5, channels: [%{ name: "Intensity", dmx_address: 1, type: :intensity }]}
    ]

    scenes = [
      %{id: 1, label: "Moody", description: "A moody lighting scene.", scene: %{fixture_id: 1, values: %{"Intensity" => 20}}},
      %{id: 2, label: "Party", description: "A vibrant party lighting scene.", scene: %{fixture_id: 2, values: %{"Intensity" => 100}}},
      %{id: 3, label: "Relax", description: "A relaxing lighting scene.", scene: %{fixture_id: 3, values: %{"Intensity" => 50}}},
    ]

    {:ok, assign(socket, :cards, cards)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex-grow w-full h-full grid grid-cols-2 xl:grid-cols-4 grid-rows-2 gap-4 p-4">
      <%= for card <- @cards do %>
        <div class={"bg-neutral-800 p-4 rounded-lg shadow-md col-span-#{card.cols} flex flex-col items-center justify-center"}>
          <i class={card.icon <> " text-3xl mb-2"}></i>
          <p class="text-sm text-gray-400"><%= card.description %></p>
        </div>
      <% end %>
    </div>
    <!-- This div is here to force css compiler to include the grid layout classes -->
    <div class="col-span-1 col-span-2" />
    """
  end
end
