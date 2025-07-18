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

    LiveLightingControl.SACNSender.send_packet(output)

    schedule_tick()

    {:noreply, state}
  end

  ## Helper functions

  defp schedule_tick do
    Process.send_after(self(), :tick, 50)
  end

  defp calculate_output do
    scenes = LiveLightingControl.SceneManager.get_scenes()
    programmer = LiveLightingControl.ProgrammerManager.get_programmer()
    fixtures = LiveLightingControl.FixtureManager.get_fixtures_map()
    fixture_types_map = LiveLightingControl.FixtureManager.get_fixture_types_map()

    universes = fixtures
      |> Map.values()
      |> Enum.map(& &1.universe)
      |> Enum.uniq()

    output =
      Enum.map(universes, fn universe_number ->
        output_for_universe =
          LiveLightingControl.OutputCalculator.calculate_output(
            scenes,
            programmer,
            fixtures,
            fixture_types_map,
            universe_number
          )

        {universe_number, output_for_universe}
      end)
      |> Map.new()

    output
  end
end
