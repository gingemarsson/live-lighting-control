defmodule LiveLightingControl.StateManager do
  use GenServer

  alias LiveLightingControl.Utils
  alias LiveLightingControl.CommonTypes

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec get_state() :: State.t()
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def execute_command(command, parameters) do
    GenServer.cast(
      __MODULE__,
      {:execute_command, %{command: command, parameters: parameters}}
    )
  end

  defp update_element_in_list_by_id(list, partial_element) do
    GenServer.cast(
      __MODULE__,
      {:update_element_in_list_by_id, %{list: list, partial_element: partial_element}}
    )
  end

  def update_scene(updated_scene) do
    update_element_in_list_by_id(:scenes, updated_scene)
  end

  def clear_active_with_fade_out_completed() do
    GenServer.cast(__MODULE__, {:clear_active_with_fade_out_completed, nil})
  end

  @spec update_programmer(%{
          :attributes => [%{attribute: CommonTypes.attribute_id(), value: integer()}],
          :fixture_ids => [CommonTypes.fixture_id()]
        }) :: :ok
  def update_programmer(%{fixture_ids: _fixture_ids, attributes: _attributes} = update) do
    GenServer.cast(__MODULE__, {:update_programmer, update})
  end

  def clear_programmer() do
    GenServer.cast(__MODULE__, {:clear_programmer, nil})
  end

  def update_executor(executor_id, update_fn) do
    GenServer.cast(
      __MODULE__,
      {:update_executor, %{executor_id: executor_id, update_fn: update_fn}}
    )
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    initial_state = LiveLightingControl.InitialState.get_initial_state()
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(
        {:update_element_in_list_by_id, %{list: list_key, partial_element: partial_element}},
        state
      ) do
    element_id = partial_element.id
    list = Map.get(state, list_key)

    existing = Utils.find_in_list_by_id(list, %{id: element_id}, element_id)
    updated = Utils.deep_merge(existing, partial_element)

    updated_list = Utils.update_element_in_list_by_id(list, element_id, fn _ -> updated end)
    updated_state = Map.put(state, list_key, updated_list)

    notify_state_updated(updated_state)
    {:noreply, updated_state}
  end

  @impl true
  def handle_cast(
        {:update_programmer, %{fixture_ids: fixture_ids, attributes: attributes}},
        state
      ) do
    programmer = Map.get(state, :programmer)

    updated_programmer =
      Enum.reduce(fixture_ids, programmer, fn fixture_id, acc ->
        fixture_values = Map.get(acc, fixture_id, %{})

        updated_fixture_values =
          Enum.reduce(attributes, fixture_values, fn %{attribute: attr, value: val}, fv_acc ->
            Map.put(fv_acc, attr, val)
          end)

        Map.put(acc, fixture_id, updated_fixture_values)
      end)

    updated_state = Map.put(state, :programmer, updated_programmer)

    notify_state_updated(updated_state)
    {:noreply, updated_state}
  end

  @impl true
  def handle_cast({:clear_programmer, _data}, state) do
    updated_programmer = %{}
    updated_state = Map.put(state, :programmer, updated_programmer)

    notify_state_updated(updated_state)
    {:noreply, updated_state}
  end

  @impl true
  def handle_cast({:update_executor, %{executor_id: executor_id, update_fn: update_fn}}, state) do
    executor_pages = state.executor_pages

    updated_executor_pages =
      Enum.map(executor_pages, fn page ->
        %{
          page
          | executors: update_element_in_2d_list_by_id(page.executors, executor_id, update_fn)
        }
      end)

    updated_state = Map.put(state, :executor_pages, updated_executor_pages)

    notify_state_updated(updated_state)
    {:noreply, updated_state}
  end

  @impl true
  def handle_cast(
        {:clear_active_with_fade_out_completed, _data},
        state
      ) do
    active_list = Map.get(state, :active)
    current_time = System.os_time(:millisecond)

    updated_list =
      Enum.filter(active_list, fn %{fade_out_completed_time: fade_out_completed_time} ->
        !(current_time > fade_out_completed_time)
      end)

    updated_state = Map.put(state, :active, updated_list)

    notify_state_updated(updated_state)
    {:noreply, updated_state}

    {:noreply, updated_state}
  end

  @impl true
  def handle_cast(
        {:execute_command, %{command: command, parameters: parameters}},
        state
      ) do

    Utils.color_puts(:magenta, "[EXECUTE COMMAND] " <> Atom.to_string(command) <> " " <> inspect(parameters))
    updated_state = LiveLightingControl.StateManagerCommandHandler.execute_command(command, parameters, state)

    updated_state_with_command_history = %{updated_state | command_history: updated_state.command_history ++ [LiveLightingControl.TextCommandHandler.get_text_command(command, parameters)]}

    notify_state_updated(updated_state_with_command_history)
    {:noreply, updated_state_with_command_history}
  end

  # Helper functions

  defp update_element_in_2d_list_by_id(list, target_id, update_fn) do
    Enum.map(list, fn row ->
      Enum.map(row, fn
        %{id: ^target_id} = exec -> update_fn.(exec)
        exec -> exec
      end)
    end)
  end

  defp notify_state_updated(updated_state) do
    Phoenix.PubSub.broadcast(
      LiveLightingControl.PubSub,
      "state",
      {:state_update, updated_state}
    )
  end
end
