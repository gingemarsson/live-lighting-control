defmodule LiveLightingControl.OutputBroadcaster do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Server Callbacks

  @impl true
  def init(state) do
    # Schedule the first tick
    schedule_tick()
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    output = calculate_output()

    Phoenix.PubSub.broadcast(LiveLightingControl.PubSub, "output", {:output_update, output})

    config = LiveLightingControl.StateManager.get_state().config

    if config.enable_sacn_output do
      LiveLightingControl.SACNSender.send_packet(output)
    end

    schedule_tick()

    {:noreply, state}
  end

  ## Helper functions

  defp schedule_tick do
    Process.send_after(self(), :tick, 50)
  end

  defp calculate_output do
    state = LiveLightingControl.StateManager.get_state()
    config = state.config
    scenes = state.scenes
    programmer = state.programmer
    users = state.users
    fixtures_map = Map.new(state.fixtures, &{&1.id, &1})
    fixture_types_map = Map.new(state.fixture_types, &{&1.id, &1})

    current_time = System.os_time(:millisecond)

    universes =
      state.fixtures
      |> Enum.map(& &1.universe)
      |> Enum.uniq()

    output =
      Enum.map(universes, fn universe_number ->
        output_for_universe =
          LiveLightingControl.OutputCalculator.calculate_output(
            config,
            scenes,
            programmer,
            users,
            fixtures_map,
            fixture_types_map,
            universe_number,
            current_time
          )

        {universe_number, output_for_universe}
      end)
      |> Map.new()

    output
  end
end
