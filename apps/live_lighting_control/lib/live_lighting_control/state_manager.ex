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

  defp add_element_to_list(list, element) do
    GenServer.cast(
      __MODULE__,
      {:add_element_to_list, %{list: list, element: element}}
    )
  end

  def update_scene(updated_scene) do
    update_element_in_list_by_id(:scenes, updated_scene)
  end

  def update_user(updated_user) do
    update_element_in_list_by_id(:users, updated_user)
  end

  def add_active(active_cue) do
    add_element_to_list(:active, active_cue)
  end

  def update_active_by_scene_id(scene_id, cue_ids, except_cue_ids, update_fn) do
    GenServer.cast(
      __MODULE__,
      {:update_active_by_scene_id,
       %{
         scene_id: scene_id,
         cue_ids: cue_ids,
         except_cue_ids: except_cue_ids,
         update_fn: update_fn
       }}
    )
  end

  def clear_active_with_fade_out_completed() do
    GenServer.cast(__MODULE__, {:clear_active_with_fade_out_completed, nil})
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

    existing = Utils.find_in_list_by_id(list, %{id: element_id}, element_id)
    updated = Utils.deep_merge(existing, partial_element)

    updated_list = Utils.update_element_in_list_by_id(list, element_id, fn _ -> updated end)
    updated_state = Map.put(state, list_key, updated_list)

    notify_state_updated(updated_state)
    {:noreply, updated_state}
  end

  def handle_cast(
        {:add_element_to_list, %{list: list_key, element: element}},
        state
      ) do
    list = Map.get(state, list_key)

    updated_list = [element | list]
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

  @impl true
  def handle_cast(
        {:update_active_by_scene_id,
         %{
           scene_id: scene_id,
           cue_ids: cue_ids,
           except_cue_ids: except_cue_ids,
           update_fn: update_fn
         }},
        state
      ) do
    active_list = Map.get(state, :active)

    updated_list =
      Enum.map(active_list, fn
        %{scene_id: ^scene_id, cue_id: cue_id} = exec ->
          cond do
            # Always skip if in except list
            cue_id in (except_cue_ids || []) ->
              exec

            # If cue_ids filter is provided, only update if in it
            cue_ids != nil and cue_ids != [] and cue_id not in cue_ids ->
              exec

            true ->
              update_fn.(exec)
          end

        exec ->
          exec
      end)

    updated_state = Map.put(state, :active, updated_list)

    notify_state_updated(updated_state)
    {:noreply, updated_state}

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

    notify_state_updated(updated_state)
    {:noreply, updated_state}
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
