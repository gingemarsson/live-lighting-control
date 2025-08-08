defmodule LiveLightingControlWeb.ConfigCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS

  def get_border_color(enabled) do
    if enabled do
      "border-orange-600"
    else
      "border-neutral-600 hover:border-neutral-400"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-xs font-semibold">Config</h2>
      </div>

      <div id={"hidden-content-#{@id}"}>
        <div class="flex flex-row gap-2 p-2">
          <div
            class={"bg-neutral-800 p-2 w-32 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(@config.enable_programmer)}"}
            phx-click="toggle_config"
            phx-value-config-name="enable_programmer"
          >
            <p class="text-xs">Programmer</p>
          </div>
          <div
            class={"bg-neutral-800 p-2 w-32 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(@config.enable_scenes)}"}
            phx-click="toggle_config"
            phx-value-config-name="enable_scenes"
          >
            <p class="text-xs">Scenes</p>
          </div>
          <div
            class={"bg-neutral-800 p-2 w-32 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(@config.enable_sacn_output)}"}
            phx-click="toggle_config"
            phx-value-config-name="enable_sacn_output"
          >
            <p class="text-xs">sACN Output</p>
          </div>

          <div class="border-l-2 mx-1 border-neutral-600" />

          <div
            class={"bg-neutral-800 p-2 w-32 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(@highlight)}"}
            phx-click="execute_command"
            phx-value-action-name="highlight"
          >
            <p class="text-xs">Highlight</p>
          </div>

          <div
            class={"bg-neutral-800 p-2 w-32 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(false)}"}
            phx-click="execute_command"
            phx-value-action-name="reset_primary_selection"
          >
            <p class="text-xs">Set</p>
          </div>

          <div
            class={"bg-neutral-800 p-2 w-32 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(false)}"}
            phx-click="execute_command"
            phx-value-action-name="next_primary_selection"
          >
            <p class="text-xs">Next</p>
          </div>

          <div
            class={"bg-neutral-800 p-2 w-32 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(false)}"}
            phx-click="execute_command"
            phx-value-action-name="previous_primary_selection"
          >
            <p class="text-xs">Previous</p>
          </div>

          <div class="flex-grow" />

          <%= for user <- @users do %>
            <div
              class={"bg-neutral-800 w-32 p-2 rounded-lg flex flex-col items-center justify-center border text-center transition-colors cursor-pointer #{get_border_color(@current_user_id == user.id)}"}
              phx-click="toggle_select_user"
              phx-value-user-id={user.id}
            >
              <p class="text-xs">{user.label}</p>
            </div>
          <% end %>

          <div class="border-l-2 mx-1 border-neutral-600" />

          <%= for view <- @views do %>
            <div
              class="bg-neutral-800 w-32 p-2 rounded-lg flex flex-col items-center justify-center border text-center transition-colors cursor-pointer border-neutral-600 hover:border-neutral-400"
              phx-click="toggle_select_view"
              phx-value-view-id={view.id}
            >
              <p class="text-xs">{view.label}</p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
