defmodule LiveLightingControl.ConfigManager do
  use GenServer

  alias UUID

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec get_config() :: LiveLightingControl.Config.t()
  def get_config do
    GenServer.call(__MODULE__, :get_config)
  end

  @spec set_config(%{:config_name => String.t(), value: any()}) :: :ok
  def set_config(%{config_name: _config_name, value: _value} = update) do
    GenServer.cast(__MODULE__, {:set_config, update})
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    state = %{
      enable_programmer: true,
      enable_scenes: true,
      enable_sacn_output: false
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_config, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:set_config, %{config_name: config_name, value: value}}, state) do
    updated_state = Map.put(state, config_name, value)

    Phoenix.PubSub.broadcast(
      LiveLightingControl.PubSub,
      "config",
      {:config_updated, updated_state}
    )

    {:noreply, updated_state}
  end
end
