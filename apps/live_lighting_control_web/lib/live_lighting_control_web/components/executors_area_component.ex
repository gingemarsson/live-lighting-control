defmodule LiveLightingControlWeb.ExecutorsAreaComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS

  def get_value_for_executor(executor_index) do
    5 + 10 * executor_index
  end

  def get_label_for_executor(executor_index) do
    "Executor #{executor_index}"
  end

  def get_button_label_for_executor(_executor_index) do
    "Go"
  end

  def get_value_for_executor_button(executor_button_row_index, executor_button_col_index) do
    0
  end

  def get_label_for_executor_button(executor_button_row_index, executor_button_col_index) do
    "Ex #{executor_button_row_index}-#{executor_button_col_index}"
  end

  def get_button_label_for_executor_button(_executor_button_row_index, _executor_button_col_index) do
    "Go"
  end

  def render(assigns) do
    ~H"""
    <div class="w-full flex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg flex flex-row" phx-click={JS.toggle(to: "#hidden-content-executors")}>
        <h2 class="text-sm font-semibold">Executors</h2>
        <%!-- <button class="text-xs m-0 mx-2 px-3 py-1 rounded-sm border border-neutral-600 hover:border-neutral-400 active:border-orange-600 text-white font-semibold transition-colors" phx-click="clear-programmer">
          Clear Programmer
        </button> --%>
      </div>

      <div class="m-2 mx-auto" id="hidden-content-executors">
        <div class="flex flex-row flex-grow gap-2 h-full">
          <%= for executor_index <- 1..8 do %>
            <% value = get_value_for_executor(executor_index) %>
            <% label = get_label_for_executor(executor_index) %>
            <% button_label = get_button_label_for_executor(executor_index) %>
            <% executor_id = "executor-#{executor_index}" %>
            <.live_component
              module={LiveLightingControlWeb.ExecutorComponent}
              id={executor_id}
              value={value}
              label={label}
              button_label={button_label}
            />
          <% end %>

          <div class="border-l-2 mx-2 border-neutral-600" />

          <div class="grid grid-cols-8 gap-2">
            <%= for executor_button_row_index <- 1..4 do %>
              <%= for executor_button_col_index <- 1..8 do %>
                <% _value = get_value_for_executor_button(executor_button_row_index, executor_button_col_index) %>
                <% label = get_label_for_executor_button(executor_button_row_index, executor_button_col_index) %>
                <% button_label = get_button_label_for_executor_button(executor_button_row_index, executor_button_col_index) %>
                <% _executor_button_id = "executor-button-#{executor_button_row_index}-#{executor_button_col_index}" %>
                <div
                  class="bg-neutral-800 w-24 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer border-neutral-600 hover:border-neutral-400"
                  phx-click="trigger_executor_action"
                  phx-value-group-id={@id}
                >
                  <p class="">{label}</p>
                  <p class="text-sm">{button_label}</p>
                </div>
              <% end %>
            <% end %>
          </div>

          <div class="border-l-2 mx-2 border-neutral-600" />

          <div class="flex flex-col justify-center items-center">
            <div
              class="bg-neutral-800 w-24 h-16 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer border-neutral-600 hover:border-neutral-400"
              phx-click="trigger_executor_action"
              phx-value-group-id={@id}
            >
              <p class="">Page up</p>
            </div>

            <p class="my-3">
              Page 1
            </p>

            <div
              class="bg-neutral-800 w-24 h-16 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer border-neutral-600 hover:border-neutral-400"
              phx-click="trigger_executor_action"
              phx-value-group-id={@id}
            >
              <p class="">Page down</p>
            </div>
          </div>

          <div class="border-l-2 mx-2 border-neutral-600" />

          <% value = 50 %>
          <% label = "Transition" %>
          <% button_label = "Toggle" %>
          <.live_component
              module={LiveLightingControlWeb.ExecutorComponent}
              id={"master-executor"}
              value={value}
              label={label}
              button_label={button_label}
            />
        </div>
      </div>
    </div>
    """
  end
end
