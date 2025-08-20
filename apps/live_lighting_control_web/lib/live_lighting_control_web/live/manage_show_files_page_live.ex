defmodule LiveLightingControlWeb.ManageShowFilesPageLive do
  use LiveLightingControlWeb, :live_view
  require UUID

  def mount(_params, _session, socket) do
    state = LiveLightingControl.StateManager.get_state()
    {:ok, assign(socket, :state, state)}
  end

  def handle_info({:state_update, updated_state}, socket) do
    {:ok, assign(socket, :state, updated_state)}
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
      <div class="bg-neutral-800 rounded-lg shadow-md">
        <div class="w-full h-fullflex flex-col">
          <div class="bg-neutral-700 p-2 rounded-t-lg">
            <h2 class="text-sm font-semibold">JSON Edit</h2>
          </div>
          <div class="flex flex-col p-2">
            <form phx-submit="import-json" id="json-input" class="flex flex-col">
              <textarea
                id="json"
                name="json"
                rows="16"
                class="flex-1 bg-transparent text-neutral-100 placeholder-neutral-500 focus:outline-none rounded-lg border border-neutral-500 bg-neutral-800 px-3 py-2 font-mono text-sm"
                placeholder="{ ... }"
                phx-hook="SetValue"
              ></textarea>
              <div class="flex flex-row gap-2">
                <button
                  type="button"
                  phx-click="export-json"
                  class={"bg-neutral-800 py-1 w-16 my-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 border-neutral-600 hover:border-neutral-400 active:border-orange-600"}
                >
                  <p class="text-xs">Export</p>
                </button>
                <button
                  type="submit"
                  class={"bg-neutral-800 py-1 w-16 my-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 border-neutral-600 hover:border-neutral-400 active:border-orange-600"}
                >
                  <p class="text-xs">Import</p>
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
