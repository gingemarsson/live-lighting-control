defmodule LiveLightingControl.ProgrammerManager do
  use GenServer


  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_programmer do
    GenServer.call(__MODULE__, :get_programmer)
  end

  def clear_programmer() do
    GenServer.cast(__MODULE__, {:clear_programmer, nil})
  end

  def update_programmer(%{fixture_ids: _fixture_ids, attribute: _attribute, value: value} = update) when value < 256 and value >= 0 do
    GenServer.cast(__MODULE__, {:update_programmer, update})
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:get_programmer, _from, programmer) do
    {:reply, programmer, programmer}
  end

  @impl true
  def handle_cast({:update_programmer, %{fixture_ids: fixture_ids, attribute: attribute, value: value}}, programmer) do
    updated_programmer =
    Enum.reduce(fixture_ids, programmer, fn fixture_id, acc ->
      fixture_values = Map.get(acc, fixture_id, %{})
      updated_fixture_values = Map.put(fixture_values, attribute, value)
      Map.put(acc, fixture_id, updated_fixture_values)
    end)

    notify_programmer_updated(updated_programmer)
    {:noreply, updated_programmer}
  end

  @impl true
  def handle_cast({:clear_programmer, _data}, _programmer) do
    updated_programmer = %{}

    notify_programmer_updated(updated_programmer)
    {:noreply, updated_programmer}
  end

  defp notify_programmer_updated(updated_programmer) do
    Phoenix.PubSub.broadcast(LiveLightingControl.PubSub, "programmer", {:programmer_updated, updated_programmer})
  end
end
