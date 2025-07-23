defmodule LiveLightingControlWeb.ExecutorsAreaComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias LiveLightingControl.Utils

  def get_id_for_executor(row_number, executor_number, current_page) do
    case Utils.get_executor(row_number, executor_number, current_page) do
      nil ->
        nil

      %{id: id} ->
        id
    end
  end

  def get_active_for_executor(row_number, executor_number, current_page) do
    case Utils.get_executor(row_number, executor_number, current_page) do
      nil ->
        nil

      %{state: state} ->
        Access.get(state, :active, false)
    end
  end

  def get_value_for_executor(row_number, executor_number, current_page, scenes) do
    case Utils.get_executor(row_number, executor_number, current_page) do
      nil ->
        0

      %{type: :scene, entity_id: id} ->
        scene = Map.get(scenes, id)
        scene.state.master

      _other ->
        100
    end
  end

  def get_label_for_executor(row_number, executor_number, current_page, scenes) do
    case Utils.get_executor(row_number, executor_number, current_page) do
      nil ->
        "-"

      %{type: :scene, entity_id: id} ->
        scene = Map.get(scenes, id)
        scene.label

      _other ->
        "N/A"
    end
  end

  def get_button_label_for_executor(row_number, executor_number, current_page, _scenes) do
    case Utils.get_executor(row_number, executor_number, current_page) do
      nil ->
        "-"

      %{button_type: :go} ->
        "Go"

      %{button_type: :flash} ->
        "Flash"

      _other ->
        "N/A"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="w-full flex flex-col">
      <% current_page = Enum.at(@executor_pages, @current_page_index) %>
      <% current_page_number = @current_page_index + 1 %>
      <div
        class="bg-neutral-700 p-2 rounded-t-lg flex flex-row"
        phx-click={JS.toggle(to: "#hidden-content-executors")}
      >
        <h2 class="text-sm font-semibold">Executors</h2>
      </div>

      <div class="m-2 mx-auto" id="hidden-content-executors">
        <div class="flex flex-row flex-grow gap-2 h-full">
          <%= for executor_number <- 1..8 do %>
            <% value = get_value_for_executor(0, executor_number, current_page, @scenes) %>
            <% label = get_label_for_executor(0, executor_number, current_page, @scenes) %>
            <% button_label = get_button_label_for_executor(0, executor_number, current_page, @scenes) %>
            <% executor_id = get_id_for_executor(0, executor_number, current_page) %>
            <% executor_active =
              get_active_for_executor(
                0,
                executor_number,
                current_page
              ) %>
            <.live_component
              module={LiveLightingControlWeb.ExecutorComponent}
              id={"executor-#{current_page_number}-0-#{executor_number}"}
              executor_id={executor_id}
              executor_active={executor_active}
              value={value}
              label={label}
              button_label={button_label}
            />
          <% end %>

          <div class="border-l-2 mx-1 border-neutral-600" />
          <div class="grid grid-cols-8 gap-2">
            <%= for executor_button_row_index <- 1..4 do %>
              <%= for executor_button_col_index <- 1..8 do %>
                <% _value =
                  get_value_for_executor(
                    executor_button_row_index,
                    executor_button_col_index,
                    current_page,
                    @scenes
                  ) %>
                <% label =
                  get_label_for_executor(
                    executor_button_row_index,
                    executor_button_col_index,
                    current_page,
                    @scenes
                  ) %>
                <% button_label =
                  get_button_label_for_executor(
                    executor_button_row_index,
                    executor_button_col_index,
                    current_page,
                    @scenes
                  ) %>
                <% executor_id =
                  get_id_for_executor(
                    executor_button_row_index,
                    executor_button_col_index,
                    current_page
                  ) %>
                <% executor_active =
                  get_active_for_executor(
                    executor_button_row_index,
                    executor_button_col_index,
                    current_page
                  ) %>

                <button
                  phx-hook="ExecutorButtonHook"
                  id={"executor-#{current_page_number}-#{executor_button_row_index}-#{executor_button_col_index}"}
                  data-executor-id={executor_id}
                  class={"bg-neutral-800 w-24 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 #{if executor_active do "border-orange-600" else "border-neutral-600 hover:border-neutral-400" end}"}
                  disabled={executor_id == nil}
                >
                  <p class="">{label}</p>
                  <p class="text-sm">{button_label}</p>
                </button>
              <% end %>
            <% end %>
          </div>

          <div class="border-l-2 mx-1 border-neutral-600" />

          <div class="flex flex-col justify-center items-center">
            <div
              class="bg-neutral-800 w-16 h-16 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer border-neutral-600 hover:border-neutral-400"
              phx-click="page_up"
            >
              <p class="">Up</p>
            </div>

            <p class="my-3">
              {current_page.label}
            </p>

            <div
              class="bg-neutral-800 w-16 h-16 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer border-neutral-600 hover:border-neutral-400"
              phx-click="page_down"
            >
              <p class="">Down</p>
            </div>
          </div>

          <div class="border-l-2 mx-1 border-neutral-600" />

          <.live_component
            module={LiveLightingControlWeb.ExecutorComponent}
            id="master-executor"
            executor_id="master-executor"
            executor_active={@config.blackout}
            value={@config.main_master}
            label="Main Master"
            button_label="Blackout"
          />
        </div>
      </div>
    </div>
    """
  end
end
