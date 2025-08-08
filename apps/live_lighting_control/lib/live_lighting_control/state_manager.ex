defmodule LiveLightingControl.StateManager do
  use GenServer

  alias LiveLightingControl.Utils

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec get_state() :: State.t()
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
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

  def update_user(updated_user) do
    update_element_in_list_by_id(:users, updated_user)
  end

  @spec set_config(%{:config_name => String.t(), value: any()}) :: :ok
  def set_config(%{config_name: _config_name, value: _value} = update) do
    GenServer.cast(__MODULE__, {:set_config, update})
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

    existing = Enum.find(list, %{id: element_id}, fn %{id: id} -> id == element_id end)
    updated = Utils.deep_merge(existing, partial_element)

    updated_list = update_element_in_list_by_id(list, element_id, fn _ -> updated end)
    updated_state = Map.put(state, list_key, updated_list)

    notify_state_updated(updated_state)
    {:noreply, updated_state}
  end

  @impl true
  def handle_cast({:set_config, %{config_name: config_name, value: value}}, state) do
    config = Map.get(state, :config)

    updated_config = Map.put(config, config_name, value)
    updated_state = Map.put(state, :config, updated_config)

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

  # Helper functions

  defp update_element_in_list_by_id(list, target_id, update_fn) do
    Enum.map(list, fn
      %{id: ^target_id} = exec -> update_fn.(exec)
      exec -> exec
    end)
  end

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
