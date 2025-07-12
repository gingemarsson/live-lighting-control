defmodule LiveLightingControlWeb.OutputCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <div class="w-full h-fullflex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-sm font-semibold">Output Preview</h2>
      </div>

      <div id={"hidden-content-#{@id}"}>
        <%= for {universe_number, values} <- Map.to_list(@output) do %>
          <h3 class="p-1 text-sm font-semibold">Universe {universe_number}</h3>

          <div class="grid grid-cols-64 gap-0">
            <%= for {value, _index} <- Enum.with_index(values) do %>
              <% color = "rgb(#{value}, #{value}, #{value})" %>
              <div
                class="flex items-center justify-center text-xs font-mono py-2"
                style={"background-color: #{color}; color: #{if value > 128, do: "black", else: "white"};"}
              >
                {trunc(value)}
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
