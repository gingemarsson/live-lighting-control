defmodule LiveLightingControlWeb.ManageShowFilesPageLive do
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

  def handle_event("delete-show-file", %{"show-file-name" => name}, socket) do
    LiveLightingControl.ShowFileManager.delete_show_file(name)

    show_files = LiveLightingControl.ShowFileManager.get_show_files()
    {:noreply, assign(socket, :show_files, show_files)}
  end

  def handle_event("load-show-file", %{"show-file-name" => name}, socket) do
    show_files = LiveLightingControl.ShowFileManager.get_show_files()
    show_file = Enum.find(show_files, fn show_file -> show_file.name == name end)

    LiveLightingControl.StateManager.import_state_from_json(show_file.json)

    {:noreply, socket}
  end

  def handle_event("save-show-file", %{"show-file-name" => name}, socket) do
    json = Jason.encode!(socket.assigns.state)

    LiveLightingControl.ShowFileManager.upsert_show_file(name, json)

    show_files = LiveLightingControl.ShowFileManager.get_show_files()
    {:noreply, assign(socket, :show_files, show_files)}
  end

  def handle_event("save-show-file-as-new", %{"show-file-name" => name}, socket) do
    json = Jason.encode!(socket.assigns.state)

    LiveLightingControl.ShowFileManager.insert_show_file(name, json)

    show_files = LiveLightingControl.ShowFileManager.get_show_files()

    {:noreply, assign(socket, :show_files, show_files)}
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
            <h2 class="text-sm font-semibold">Show Files Database</h2>
          </div>
          <div class="flex flex-col p-2">
            <div class="grid grid-cols-8 gap-2">
              <%= for show_file <- Enum.sort_by(@show_files, fn show_file -> show_file.updated_at end, :desc) do %>
                <div
                  class={"bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors border-neutral-500"}
                >
                  <p class="">{show_file.name}</p>
                  <p class="text-sm text-neutral-400"><%= Calendar.strftime(show_file.updated_at, "%Y-%m-%d %H:%M") %></p>
                  <div class="flex flex-row gap-2">
                    <button
                      type="button"
                      phx-click="save-show-file"
                      phx-value-show-file-name={show_file.name}
                      class={"bg-neutral-800 py-1 w-16 my-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 border-neutral-600 hover:border-neutral-400 active:border-orange-600"}
                    >
                      <p class="text-xs">Save</p>
                    </button>
                    <button
                      type="button"
                      phx-click="load-show-file"
                      phx-value-show-file-name={show_file.name}
                      class={"bg-neutral-800 py-1 w-16 my-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 border-neutral-600 hover:border-neutral-400 active:border-orange-600"}
                    >
                      <p class="text-xs">Load</p>
                    </button>
                    <button
                      type="button"
                      phx-click="delete-show-file"
                      phx-value-show-file-name={show_file.name}
                      class={"bg-neutral-800 py-1 w-16 my-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 border-neutral-600 hover:border-neutral-400 active:border-orange-600"}
                    >
                      <p class="text-xs">Delete</p>
                    </button>
                  </div>
                </div>
              <% end %>
            </div>


              <form phx-submit="save-show-file-as-new" id="show-file-form" class="mt-4 pt-4 flex flex-row gap-2 border-t border-neutral-500">
          <input
            id="show-file-name"
            name="show-file-name"
            class="bg-transparent text-neutral-100 placeholder-neutral-500 focus:outline-none rounded-lg border border-neutral-500 bg-neutral-800 px-3 py-2 font-mono text-sm w-96"
            placeholder="my-show-file"
            phx-debounce="300"
            autocomplete="off"
            spellcheck="false"
            autocorrect="off"
            autocapitalize="off"
          />
          <button
                type="submit"
                class={"bg-neutral-800 py-1 px-3 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 border-neutral-600 hover:border-neutral-400 active:border-orange-600"}
              >
                <p class="text-xs">Save as new show file</p>
              </button>
        </form>
          </div>
        </div>
      </div>


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
