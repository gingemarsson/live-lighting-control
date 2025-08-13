defmodule LiveLightingControlWeb.ControlPageLive do
  use LiveLightingControlWeb, :live_view
  require UUID
  alias LiveLightingControl.Models.Scene
  alias LiveLightingControl.Models.Cue
  alias LiveLightingControl.Utils
  alias LiveLightingControl.MidiUtils

  def mount(_params, _session, socket) do
    cards = [
      %{id: UUID.uuid4(), type: :config, configuration: %{}},
      %{id: UUID.uuid4(), type: :fixture_groups, configuration: %{}},
      %{id: UUID.uuid4(), type: :fixtures, configuration: %{}},
      %{id: UUID.uuid4(), type: :output, configuration: %{}}
    ]

    Phoenix.PubSub.subscribe(LiveLightingControl.PubSub, "state")
    Phoenix.PubSub.subscribe(LiveLightingControl.PubSub, "output")

    state = LiveLightingControl.StateManager.get_state()
    user = List.first(state.users)

    {:ok,
     assign(socket,
       # State
       config: state.config,
       programmer: state.programmer,
       fixtures: state.fixtures,
       fixture_types: state.fixture_types,
       fixture_groups: state.fixture_groups,
       executor_pages: state.executor_pages,
       layouts: state.layouts,
       views: state.views,
       scenes: state.scenes,
       users: state.users,
       active: state.active,
       command_history: state.command_history,
       # Maps
       fixtures_map: Map.new(state.fixtures, &{&1.id, &1}),
       fixture_types_map: Map.new(state.fixture_types, &{&1.id, &1}),
       fixture_groups_map: Map.new(state.fixture_groups, &{&1.id, &1}),
       layouts_map: Map.new(state.layouts, &{&1.id, &1}),
       views_map: Map.new(state.views, &{&1.id, &1}),
       scenes_map: Map.new(state.scenes, &{&1.id, &1}),
       # User
       selected_fixture_ids: user.selected_fixture_ids,
       primary_selected_fixture_id: user.primary_selected_fixture_id,
       current_page_index: user.current_page_index,
       highlight: user.highlight,
       # Output
       output: %{},
       # Local
       cards: cards,
       current_user_id: user.id,
       command: "",
       command_history_index: 0
     )}
  end

  # Subscriptions from other parts of application

  def handle_info({:state_update, updated_state}, socket) do
    user = Utils.find_in_list_by_id(updated_state.users, socket.assigns.current_user_id)

    # Always update all scenes
    {:noreply,
     assign(socket,
       config: updated_state.config,
       programmer: updated_state.programmer,
       fixtures: updated_state.fixtures,
       fixture_types: updated_state.fixture_types,
       fixture_groups: updated_state.fixture_groups,
       executor_pages: updated_state.executor_pages,
       layouts: updated_state.layouts,
       views: updated_state.views,
       scenes: updated_state.scenes,
       users: updated_state.users,
       active: updated_state.active,
       command_history: updated_state.command_history,
       # Maps
       fixtures_map: Map.new(updated_state.fixtures, &{&1.id, &1}),
       fixture_types_map: Map.new(updated_state.fixture_types, &{&1.id, &1}),
       fixture_groups_map: Map.new(updated_state.fixture_groups, &{&1.id, &1}),
       layouts_map: Map.new(updated_state.layouts, &{&1.id, &1}),
       views_map: Map.new(updated_state.views, &{&1.id, &1}),
       scenes_map: Map.new(updated_state.scenes, &{&1.id, &1}),
       # User
       selected_fixture_ids: user.selected_fixture_ids,
       primary_selected_fixture_id: user.primary_selected_fixture_id,
       current_page_index: user.current_page_index,
       highlight: user.highlight
     )}
  end

  def handle_info({:output_update, output}, socket) do
    {:noreply, assign(socket, :output, output)}
  end

  # Page events

  def handle_event(
        "click_entity",
        %{"entity-type" => "fixture", "entity-id" => fixture_id},
        socket
      ) do
    LiveLightingControl.StateManager.execute_command(:toggle_select_fixture, %{fixture_id: fixture_id, user_id: socket.assigns.current_user_id})
    {:noreply, socket}
  end

  def handle_event(
        "click_entity",
        %{"entity-type" => "fixture_group", "entity-id" => group_id},
        socket
      ) do
    LiveLightingControl.StateManager.execute_command(:toggle_select_fixture_group, %{fixture_group_id: group_id, user_id: socket.assigns.current_user_id})
    {:noreply, socket}
  end

  def handle_event(
        "click_entity",
        %{"entity-type" => "active", "entity-id" => active_id},
        socket
      ) do
    active = Utils.find_in_list_by_id(socket.assigns.active, active_id)
    LiveLightingControl.StateManager.execute_command(:off, %{scene_id: active.scene_id, user_id: socket.assigns.current_user_id})
    {:noreply, socket}
  end

  def handle_event(
        "update_card_configuration",
        %{"key" => key_string, "value" => value, "card-id" => card_id},
        socket
      ) do
    cards = socket.assigns.cards
    key = String.to_existing_atom(key_string)

    updated_cards =
      Enum.map(cards, fn card ->
        if card.id == card_id do
          %{card | configuration: Map.merge(card.configuration, %{key => value})}
        else
          card
        end
      end)

    {:noreply, assign(socket, :cards, updated_cards)}
  end

  def handle_event("toggle_select_view", %{"view-id" => view_id}, socket) do
    views_map = socket.assigns.views_map
    selected_view = Map.get(views_map, view_id)

    {:noreply, assign(socket, :cards, selected_view.cards)}
  end

  def handle_event("toggle_select_user", %{"user-id" => user_id}, socket) do
    user = Utils.find_in_list_by_id(socket.assigns.users, user_id)

    {:noreply,
     assign(socket,
       current_user_id: user_id,
       selected_fixture_ids: user.selected_fixture_ids,
       primary_selected_fixture_id: user.primary_selected_fixture_id,
       current_page_index: user.current_page_index,
       highlight: user.highlight
     )}
  end

  def handle_event(
        "slider_changed",
        %{"value" => master_value, "sliderId" => scene_id, "sliderType" => "scene"},
        socket
      ) do
    LiveLightingControl.StateManager.update_scene(%{id: scene_id, state: %{master: master_value}})

    {:noreply, socket}
  end

  def handle_event(
        "slider_changed",
        %{"value" => value, "sliderId" => attribute, "sliderType" => "programmer"},
        socket
      ) do
    selected_fixture_ids =
      if socket.assigns.primary_selected_fixture_id != nil do
        [socket.assigns.primary_selected_fixture_id]
      else
        socket.assigns.selected_fixture_ids
      end

    LiveLightingControl.StateManager.update_programmer(%{
      fixture_ids: selected_fixture_ids,
      attributes: [%{attribute: attribute, value: round(value)}]
    })

    {:noreply, socket}
  end

  def handle_event(
        "slider_changed",
        %{"value" => value, "sliderId" => "master-executor", "sliderType" => "executor"},
        socket
      ) do
    execute_command(socket, :main_master, value)
  end

  def handle_event(
        "slider_changed",
        %{"value" => value, "sliderId" => executor_id, "sliderType" => "executor"},
        socket
      ) do
    LiveLightingControl.ExecutorManager.handle_executor_slider(
      executor_id,
      value
    )

    {:noreply, socket}
  end

  def handle_event(
        "trigger_executor_action_button_down",
        %{"executorId" => "master-executor"},
        socket
      ) do
    execute_command(socket, :toggle_blackout, nil)

    {:noreply, socket}
  end

  def handle_event(
        "trigger_executor_action_button_down",
        %{"executorId" => executor_id},
        socket
      ) do
    LiveLightingControl.ExecutorManager.handle_executor_action(
      executor_id,
      :button_down
    )

    {:noreply, socket}
  end

  def handle_event(
        "trigger_executor_action_button_up",
        %{"executorId" => executor_id},
        socket
      ) do
    LiveLightingControl.ExecutorManager.handle_executor_action(
      executor_id,
      :button_up
    )

    {:noreply, socket}
  end

  def handle_event("execute_command", %{"command" => command_string}, socket) do
    execute_command(socket, String.to_existing_atom(command_string), nil)
  end

  def handle_event(
        "color_changed",
        %{
          "red" => value_red,
          "green" => value_green,
          "blue" => value_blue,
          "colorPickerType" => "programmer"
        },
        socket
      ) do
    selected_fixture_ids =
      if socket.assigns.primary_selected_fixture_id != nil do
        [socket.assigns.primary_selected_fixture_id]
      else
        socket.assigns.selected_fixture_ids
      end

    LiveLightingControl.StateManager.update_programmer(%{
      fixture_ids: selected_fixture_ids,
      attributes: [
        %{attribute: "red", value: round(value_red)},
        %{attribute: "green", value: round(value_green)},
        %{attribute: "blue", value: round(value_blue)}
      ]
    })

    {:noreply, socket}
  end

  # Command line

  def handle_event("execute_text_command", %{"command" => command}, socket) do
    LiveLightingControl.TextCommandHandler.execute_text_command(command, socket.assigns.current_user_id)
    {:noreply, assign(socket, command: "", command_history_index: 0) |> push_event("set-command", %{value: ""})}
  end

  def handle_event("command_change", %{"command" => command}, socket) do
    {:noreply, assign(socket, command: command)}
  end

  def handle_event("navigate_command_history", %{"key" => "ArrowUp"}, socket) do
    history_length = length(socket.assigns.command_history)
    new_index = min(history_length, socket.assigns.command_history_index + 1)
    command = Enum.at(socket.assigns.command_history, history_length - new_index)

    {:noreply, assign(socket,
    command_history_index: new_index,
    command: command
    ) |> push_event("set-command", %{value: command})}
  end

  def handle_event("navigate_command_history", %{"key" => "ArrowDown"}, socket) do
    history_length = length(socket.assigns.command_history)
    new_index = max(0, socket.assigns.command_history_index - 1)
    command = Enum.at(socket.assigns.command_history, history_length - new_index)

    {:noreply, assign(socket,
    command_history_index: new_index,
    command: command
    ) |> push_event("set-command", %{value: command})}
  end

  def handle_event("navigate_command_history", _data, socket) do
    {:noreply, socket}
  end

  # General commands

  def handle_event("execute_command", %{"action-name" => action_name}, socket) do
    execute_command(socket, String.to_existing_atom(action_name), nil)
  end

# Programmer

  def handle_event("clear-programmer", _data, socket) do
    LiveLightingControl.StateManager.clear_programmer()

    {:noreply, socket}
  end

  def handle_event("save-programmer", _data, socket) do
    new_scene = %Scene{
      id: UUID.uuid4(),
      label: "New scene",
      cues: [
        %Cue{id: UUID.uuid4(), label: "Cue 1", fixture_attribute_map: socket.assigns.programmer}
      ],
      state: %{master: 100}
    }

    LiveLightingControl.StateManager.update_scene(new_scene)

    {:noreply, socket}
  end

  def handle_event(
        "midi_event",
        %{
          "data1" => element_id,
          "data2" => raw_value,
          "status" => status
        },
        socket
      ) do
    action = MidiUtils.get_action_from_midi_status(status)

    case MidiUtils.get_executor_position_or_command_from_midi(element_id, action) do
      %{type: :executor_position, row_number: row_number, executor_number: executor_number} ->
        current_page = Enum.at(socket.assigns.executor_pages, socket.assigns.current_page_index)
        executor = Utils.get_executor(row_number, executor_number, current_page)

        if executor do
          case action do
            :button_down ->
              LiveLightingControl.ExecutorManager.handle_executor_action(
                executor.id,
                :button_down
              )

              {:noreply, socket}

            :button_up ->
              LiveLightingControl.ExecutorManager.handle_executor_action(
                executor.id,
                :button_up
              )

              {:noreply, socket}

            :slider_change ->
              LiveLightingControl.ExecutorManager.handle_executor_slider(
                executor.id,
                MidiUtils.get_value_from_midi_value(raw_value)
              )

              {:noreply, socket}
          end
        else
          {:noreply, socket}
        end

      %{type: :command, command: command} when action == :button_down ->
        execute_command(socket, command, nil)

      %{type: :command, command: :main_master} when action == :slider_change ->
        execute_command(socket, :main_master, MidiUtils.get_value_from_midi_value(raw_value))

      _ ->
        {:noreply, socket}
    end
  end

  def execute_command(socket, command, value) do
    LiveLightingControl.StateManager.execute_command(command, %{value: value, user_id: socket.assigns.current_user_id})
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex-grow w-full max-w-[1920px] mx-auto flex flex-col gap-4 p-4 pb-96">
      <%= for card <- @cards do %>
        <div class="bg-neutral-800 rounded-lg shadow-md">
          <%= case card.type do %>
            <% :config -> %>
              <.live_component
                module={LiveLightingControlWeb.ConfigCardComponent}
                id={card.id}
                config={@config}
                views={@views}
                users={@users}
                current_user_id={@current_user_id}
                highlight={@highlight}
              />
            <% :fixtures -> %>
              <.live_component
                module={LiveLightingControlWeb.FixturesLibraryCardComponent}
                id={card.id}
                fixtures={@fixtures}
                selected_fixture_ids={@selected_fixture_ids}
                primary_selected_fixture_id={@primary_selected_fixture_id}
              />
            <% :fixture_groups -> %>
              <.live_component
                module={LiveLightingControlWeb.FixtureGroupsLibraryCardComponent}
                id={card.id}
                fixture_groups={@fixture_groups}
                selected_fixture_ids={@selected_fixture_ids}
              />
            <% :layouts -> %>
              <.live_component
                module={LiveLightingControlWeb.LayoutsCardComponent}
                id={card.id}
                layouts_map={@layouts_map}
                configuration={card.configuration}
                selected_fixture_ids={@selected_fixture_ids}
                primary_selected_fixture_id={@primary_selected_fixture_id}
              />
            <% :scenes -> %>
              <.live_component
                module={LiveLightingControlWeb.ScenesLibraryCardComponent}
                id={card.id}
                scenes={@scenes_map}
              />
            <% :output -> %>
              <.live_component
                module={LiveLightingControlWeb.OutputCardComponent}
                id={card.id}
                output={@output}
                selected_fixture_ids={@selected_fixture_ids}
                primary_selected_fixture_id={@primary_selected_fixture_id}
                fixtures={@fixtures_map}
                fixture_types={@fixture_types_map}
              />
            <% :selected_fixtures-> %>
              <.live_component
                module={LiveLightingControlWeb.SelectedFixturesCardComponent}
                id={card.id}
                fixtures={@fixtures}
                selected_fixture_ids={@selected_fixture_ids}
                primary_selected_fixture_id={@primary_selected_fixture_id}
              />
            <% :programmer-> %>
              <.live_component
                module={LiveLightingControlWeb.ProgrammerCardComponent}
                id={card.id}
                programmer={@programmer}
                fixtures={@fixtures}
                fixture_types={Map.values(@fixture_types_map)}
                selected_fixture_ids={@selected_fixture_ids}
                primary_selected_fixture_id={@primary_selected_fixture_id}
              />
            <% :active-> %>
              <.live_component
                module={LiveLightingControlWeb.ActiveCardComponent}
                id={card.id}
                active={@active}
                scenes={@scenes}
                output={@output}
              />
          <% end %>
        </div>
      <% end %>
    </div>

    <div class="fixed bottom-0 left-0 w-full bg-neutral-800 ">
      <div class="m-2 mx-auto" style="max-width: 1800px">
        <div class="w-full flex flex-col gap-2">
          <.live_component
            module={LiveLightingControlWeb.ExecutorsAreaComponent}
            id="executors"
            executor_pages={@executor_pages}
            current_page_index={@current_page_index}
            scenes={@scenes_map}
            config={@config}
          />
          <.live_component
            module={LiveLightingControlWeb.CommandLineComponent}
            id="command-line"
            config={@config}
            command={@command}
            command_history={@command_history}
          />
        </div>
      </div>
    </div>

    <div id="midi" phx-hook="MidiHook" />

    <div class="col-span-1 col-span-2 col-span-3 col-span-4" />
    """
  end
end
