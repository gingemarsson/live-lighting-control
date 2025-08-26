defmodule LiveLightingControlWeb.ManageFixturesLive do
  use LiveLightingControlWeb, :live_view
  require UUID

  def mount(_params, _session, socket) do
    state = LiveLightingControl.StateManager.get_state()
    show_files = LiveLightingControl.ShowFileManager.get_show_files()

    Phoenix.PubSub.subscribe(LiveLightingControl.PubSub, "state")

    {:ok, assign(socket, state: state, show_files: show_files)}
  end

  def handle_info({:state_update, updated_state}, socket) do
    {:noreply, assign(socket, :state, updated_state)}
  end

  def handle_event("export-json", _data, socket) do
    json = Jason.encode!(socket.assigns.state, pretty: true)
    {:noreply, push_event(socket, "set-value", %{value: json})}
  end

  def handle_event("import-json", %{"json" => json_data}, socket) do
    LiveLightingControl.StateManager.import_state_from_json(json_data)
    {:noreply, push_event(socket, "set-value", %{value: json_data})}
  end

  def render(assigns) do
    ~H"""
    <div class="flex-grow w-full max-w-[1920px] mx-auto flex flex-col gap-4 p-4 pb-96">
    <a href={~p"/manage-fixture-types"} class="hover:text-zinc-100 ml-3">
        Manage fixture types
      </a>
    </div>
    """
  end
end
