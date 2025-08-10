defmodule LiveLightingControlWeb.ExecutorsAreaComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias LiveLightingControl.Utils

  def get_executor_info(row_number, executor_number, current_page, scenes) do
    case Utils.get_executor(row_number, executor_number, current_page) do
      nil ->
        %{
          id: nil,
          active: nil,
          value: 0,
          label: "-",
          cues: [],
          current_cue_index: nil,
          button_label: "-"
        }

      %{id: id, state: state} = executor ->
        scene =
          case executor do
            %{type: :scene, entity_id: scene_id} -> Map.get(scenes, scene_id)
            _ -> nil
          end

        %{
          id: id,
          active: Access.get(state, :active, false),
          value: get_value(executor, scene),
          label: get_label(executor, scene),
          cues: get_cues(executor, scene),
          current_cue_index: get_current_cue_index(executor, scene),
          button_label: get_button_label(executor)
        }
    end
  end

  defp get_value(%{type: :scene}, %{state: %{master: master}}), do: master
  defp get_value(_, _), do: 100

  defp get_label(%{type: :scene}, %{label: label}), do: label
  defp get_label(_, _), do: "N/A"

  defp get_cues(%{type: :scene}, %{cues: cues}), do: cues
  defp get_cues(_, _), do: []

  defp get_current_cue_index(%{type: :scene}, %{state: %{cue_index: cue_index}}), do: cue_index
  defp get_current_cue_index(_, _), do: nil

  defp get_button_label(%{button_type: :go}), do: "Go"
  defp get_button_label(%{button_type: :flash}), do: "Flash"
  defp get_button_label(%{button_type: :next}), do: "Next"
  defp get_button_label(%{button_type: :previous}), do: "Prev"
  defp get_button_label(_), do: "N/A"

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
            <% executor_info = get_executor_info(0, executor_number, current_page, @scenes) %>
            <%!-- <% value = get_value_for_executor(0, executor_number, current_page, @scenes) %>
            <% label = get_label_for_executor(0, executor_number, current_page, @scenes) %>
            <% cues = get_cues_for_executor(0, executor_number, current_page, @scenes) %>
            <% button_label = get_button_label_for_executor(0, executor_number, current_page, @scenes) %>
            <% executor_id = get_id_for_executor(0, executor_number, current_page) %>
            <% executor_active =
              get_active_for_executor(
                0,
                executor_number,
                current_page
              ) %> --%>
            <.live_component
              module={LiveLightingControlWeb.ExecutorComponent}
              id={"executor-#{current_page_number}-0-#{executor_number}"}
              executor_id={executor_info.id}
              executor_active={executor_info.active}
              value={executor_info.value}
              label={executor_info.label}
              button_label={executor_info.button_label}
              cues={executor_info.cues}
              current_cue_index={executor_info.current_cue_index}
            />
          <% end %>

          <div class="border-l-2 mx-1 border-neutral-600" />

          <div class="grid grid-cols-8 gap-2">
            <%= for executor_button_row_index <- 1..4 do %>
              <%= for executor_button_col_index <- 1..8 do %>
                <% executor_info =
                  get_executor_info(
                    executor_button_row_index,
                    executor_button_col_index,
                    current_page,
                    @scenes
                  ) %>
                <button
                  phx-hook="ExecutorButtonHook"
                  id={"executor-#{current_page_number}-#{executor_button_row_index}-#{executor_button_col_index}"}
                  data-executor-id={executor_info.id}
                  class={"bg-neutral-800 w-24 py-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 #{if executor_info.active do "border-orange-600" else "border-neutral-600 hover:border-neutral-400" end}"}
                  disabled={executor_info.id == nil}
                >
                  <p class="text-sm">{executor_info.label}</p>
                  <p class="text-xs">{executor_info.button_label}</p>
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
            label="Main"
            button_label="Blackout"
            cues={[]}
            current_cue_index={nil}
          />
        </div>
      </div>
    </div>
    """
  end
end
