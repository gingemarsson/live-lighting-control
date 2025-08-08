defmodule LiveLightingControlWeb.ControlPageLive do
  use LiveLightingControlWeb, :live_view
  require UUID
  alias LiveLightingControl.Models.Scene
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
       # Output
       output: %{},
       # Local
       cards: cards,
       current_user_id: user.id
     )}
  end

  # Subscriptions from other parts of application

  def handle_info({:state_update, updated_state}, socket) do
    user = Enum.find(updated_state.users, fn user -> (user.id == socket.assigns.current_user_id) end)

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
       current_page_index: user.current_page_index
     )}
  end

  def handle_info({:output_update, output}, socket) do
    {:noreply, assign(socket, :output, output)}
  end

  # Helper functions

  def toggle_select_fixtures(fixture_ids, selected_fixture_ids) do
    all_fixtures_are_already_selected =
      Utils.is_fixtures_selected?(fixture_ids, selected_fixture_ids) == :all

    updated_fixture_ids =
      if all_fixtures_are_already_selected do
        Enum.reject(selected_fixture_ids, fn x -> x in fixture_ids end)
      else
        selected_fixture_ids ++ fixture_ids
      end

    updated_fixture_ids
  end

  # Page events

  def handle_event("toggle_config", %{"config-name" => config_name_string}, socket) do
    config_name = String.to_existing_atom(config_name_string)

    LiveLightingControl.StateManager.set_config(%{
      config_name: config_name,
      value: !socket.assigns.config[config_name]
    })

    {:noreply, socket}
  end

  def handle_event(
        "click_entity",
        %{"entity-type" => "fixture", "entity-id" => fixture_id},
        socket
      ) do
    updated_fixture_ids =
      toggle_select_fixtures([fixture_id], socket.assigns.selected_fixture_ids)

    LiveLightingControl.StateManager.update_user(%{id: socket.assigns.current_user_id, selected_fixture_ids: updated_fixture_ids, primary_selected_fixture_id: nil})

    {:noreply, socket}
  end

  def handle_event(
        "click_entity",
        %{"entity-type" => "fixture_group", "entity-id" => group_id},
        socket
      ) do
    fixture_group = Map.get(socket.assigns.fixture_groups_map, group_id)

    updated_fixture_ids =
      toggle_select_fixtures(fixture_group.fixture_ids, socket.assigns.selected_fixture_ids)

    LiveLightingControl.StateManager.update_user(%{id: socket.assigns.current_user_id, selected_fixture_ids: updated_fixture_ids, primary_selected_fixture_id: nil})

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
    user = Enum.find(socket.assigns.users, &(&1.id == user_id))
    {:noreply, assign(socket, current_user_id: user_id, selected_fixture_ids: user.selected_fixture_ids,
    primary_selected_fixture_id: user.primary_selected_fixture_id,
    current_page_index: user.current_page_index)}
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
      value,
      socket.assigns.executor_pages
    )

    {:noreply, socket}
  end

  def handle_event(
        "trigger_executor_action_button_down",
        %{"executorId" => "master-executor"},
        socket
      ) do
    LiveLightingControl.StateManager.set_config(%{
      config_name: :blackout,
      value: !socket.assigns.config[:blackout]
    })

    {:noreply, socket}
  end

  def handle_event(
        "trigger_executor_action_button_down",
        %{"executorId" => executor_id},
        socket
      ) do
    LiveLightingControl.ExecutorManager.handle_executor_action(executor_id, :button_down, socket.assigns.executor_pages)

    {:noreply, socket}
  end

  def handle_event(
        "trigger_executor_action_button_up",
        %{"executorId" => executor_id},
        socket
      ) do
    LiveLightingControl.ExecutorManager.handle_executor_action(executor_id, :button_up, socket.assigns.executor_pages)

    {:noreply, socket}
  end

  def handle_event("page_up", _data, socket) do
    execute_command(socket, :page_up, nil)
  end

  def handle_event("page_down", _data, socket) do
    execute_command(socket, :page_down, nil)
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

  def handle_event("execute_command", %{"action-name" => action_name}, socket) do
    execute_command(socket, String.to_existing_atom(action_name), nil)
  end

  def handle_event("clear-programmer", _data, socket) do
    LiveLightingControl.StateManager.clear_programmer()

    {:noreply, socket}
  end

  def handle_event("save-programmer", _data, socket) do
    new_scene = %Scene{
      id: UUID.uuid4(),
      label: "New scene",
      fixtures: socket.assigns.programmer,
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
                :button_down,
                socket.assigns.executor_pages
              )

              {:noreply, socket}

            :button_up ->
              LiveLightingControl.ExecutorManager.handle_executor_action(
                executor.id,
                :button_up,
                socket.assigns.executor_pages
              )

              {:noreply, socket}

            :slider_change ->
              LiveLightingControl.ExecutorManager.handle_executor_slider(
                executor.id,
                MidiUtils.get_value_from_midi_value(raw_value),
                socket.assigns.executor_pages
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
    case command do
      :toggle_sacn_output ->
        LiveLightingControl.StateManager.set_config(%{
          config_name: :enable_sacn_output,
          value: !socket.assigns.config[:enable_sacn_output]
        })

        {:noreply, socket}

      :toggle_programmer ->
        LiveLightingControl.StateManager.set_config(%{
          config_name: :enable_programmer,
          value: !socket.assigns.config[:enable_programmer]
        })

        {:noreply, socket}

      :page_up ->
        LiveLightingControl.StateManager.update_user(%{id: socket.assigns.current_user_id, current_page_index: rem(socket.assigns.current_page_index + 1, length(socket.assigns.executor_pages))})
        {:noreply, socket}

      :page_down ->
        LiveLightingControl.StateManager.update_user(%{id: socket.assigns.current_user_id, current_page_index: rem(socket.assigns.current_page_index - 1, length(socket.assigns.executor_pages))})
        {:noreply, socket}

      :toggle_blackout ->
        LiveLightingControl.StateManager.set_config(%{
          config_name: :blackout,
          value: !socket.assigns.config[:blackout]
        })

        {:noreply, socket}

      :main_master ->
        LiveLightingControl.StateManager.set_config(%{
          config_name: :main_master,
          value: value
        })

        {:noreply, socket}

      :highlight ->
        IO.puts(":highlight")
        {:noreply, socket}

      :reset_primary_selection ->
        LiveLightingControl.StateManager.update_user(%{id: socket.assigns.current_user_id, primary_selected_fixture_id: nil})
        {:noreply, socket}

      :next_primary_selection ->
        current_primary_selected_fixture_id = socket.assigns.primary_selected_fixture_id
        selected_fixture_ids = socket.assigns.selected_fixture_ids

        new_primary_selected_fixture_id =
          case current_primary_selected_fixture_id do
            nil ->
              Enum.at(selected_fixture_ids, 0)

            _ ->
              current_index =
                Enum.find_index(
                  selected_fixture_ids,
                  &(&1 == current_primary_selected_fixture_id)
                )

              new_index = rem(current_index + 1, length(selected_fixture_ids))
              Enum.at(selected_fixture_ids, new_index)
          end

        LiveLightingControl.StateManager.update_user(%{id: socket.assigns.current_user_id, primary_selected_fixture_id: new_primary_selected_fixture_id})
        {:noreply, socket}

      :previous_primary_selection ->
        current_primary_selected_fixture_id = socket.assigns.primary_selected_fixture_id
        selected_fixture_ids = socket.assigns.selected_fixture_ids

        new_primary_selected_fixture_id =
          case current_primary_selected_fixture_id do
            nil ->
              Enum.at(selected_fixture_ids, 0)

            _ ->
              current_index =
                Enum.find_index(
                  selected_fixture_ids,
                  &(&1 == current_primary_selected_fixture_id)
                )

              new_index = rem(current_index - 1, length(selected_fixture_ids))
              Enum.at(selected_fixture_ids, new_index)
          end

          LiveLightingControl.StateManager.update_user(%{id: socket.assigns.current_user_id, primary_selected_fixture_id: new_primary_selected_fixture_id})
          {:noreply, socket}
      _ ->
        {:noreply, socket}
    end
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
          <% end %>
        </div>
      <% end %>
    </div>

    <div class="fixed bottom-0 left-0 w-full bg-neutral-800 ">
      <.live_component
        module={LiveLightingControlWeb.ExecutorsAreaComponent}
        id="executors"
        executor_pages={@executor_pages}
        current_page_index={@current_page_index}
        scenes={@scenes_map}
        config={@config}
      />
    </div>

    <div id="midi" phx-hook="MidiHook" />

    <div class="col-span-1 col-span-2 col-span-3 col-span-4" />
    """
  end
end
