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
    # Perform cleanup
    LiveLightingControl.StateManager.clear_active_with_fade_out_completed()

    # Generate output
    {calculated_fixture_values, dmx_output} = calculate_output()

    Phoenix.PubSub.broadcast(LiveLightingControl.PubSub, "output", {:output_update, dmx_output})
    Phoenix.PubSub.broadcast(LiveLightingControl.PubSub, "output", {:calculated_fixture_values_update, calculated_fixture_values})

    # Send sACN
    config = LiveLightingControl.StateManager.get_state().config

    if config.enable_sacn_output do
      LiveLightingControl.SACNSender.send_packet(dmx_output)
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
    active = state.active
    programmer = state.programmer
    users = state.users
    fixtures_map = Map.new(state.fixtures, &{&1.id, &1})
    fixture_types_map = Map.new(state.fixture_types, &{&1.id, &1})

    current_time = System.os_time(:millisecond)

    calculated_fixture_values = LiveLightingControl.OutputCalculator.get_calculated_fixture_values(
      config,
      active,
      scenes,
      programmer,
      users,
      current_time
    )

    universes =
      state.fixtures
      |> Enum.map(& &1.universe)
      |> Enum.uniq()

    dmx_output =
      Enum.map(universes, fn universe_number ->
        output_for_universe =
          LiveLightingControl.OutputCalculator.generate_dmx(
            calculated_fixture_values,
            fixtures_map,
            fixture_types_map,
            universe_number
          )

        {universe_number, output_for_universe}
      end)
      |> Map.new()

    {calculated_fixture_values, dmx_output}
  end
end
