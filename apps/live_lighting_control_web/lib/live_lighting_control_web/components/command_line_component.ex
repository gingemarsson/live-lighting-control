defmodule LiveLightingControlWeb.CommandLineComponent do
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
    <div>
      <div class="hidden rounded-lg border border-neutral-500 bg-neutral-800 px-3 py-2 font-mono text-xs mb-2" id="hidden-content-command-history">
        <%= for history_row <- Enum.take(@command_history, -12) do %>
        <p>> {history_row}</p>
        <% end %>
      </div>
      <div class="flex flex-row flex-grow gap-2">
      <form phx-change="command_change" phx-submit="execute_text_command" id="command-line-form" class="flex flex-grow items-center rounded-lg border border-neutral-500 bg-neutral-800 px-3 py-2 font-mono text-sm">
          <span class="text-neutral-400 mr-2">&gt;</span>
          <input
            id="command-line"
            name="command"
            class="flex-1 bg-transparent text-neutral-100 placeholder-neutral-500 focus:outline-none"
            placeholder=""
            phx-debounce="300"
            autocomplete="off"
            spellcheck="false"
            autocorrect="off"
            autocapitalize="off"
            phx-keydown="navigate_command_history"
            phx-hook="CommandLine"
          />
        </form>

        <div
          class={"bg-neutral-800 p-2 px-4 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(false)}"}
          phx-click={JS.toggle(to: "#hidden-content-command-history")}
        >
          <p class="text-xs">Toggle CMD History</p>
        </div>

        <div
          class={"bg-neutral-800 p-2 px-4 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(false)}"}
          phx-click={JS.toggle(to: "#hidden-content-executors")}
        >
          <p class="text-xs">Toggle executors</p>
        </div>

        <div
          class={"bg-neutral-800 p-2 px-4 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer #{get_border_color(@config.enable_sacn_output)}"}
          phx-click="execute_command"
          phx-value-command="toggle_sacn_output"
        >
          <p class="text-xs">sACN Output</p>
        </div>

      </div>
    </div>
    """
  end
end
