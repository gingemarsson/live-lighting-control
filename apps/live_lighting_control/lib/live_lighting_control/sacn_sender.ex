defmodule LiveLightingControl.SACNSender do
  use GenServer

  @universe_configuration [1,2,3,4]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_state) do
    {:ok, socket} = :gen_udp.open(0, [:binary, {:reuseaddr, true}, {:ip, {0, 0, 0, 0}}])

    state = %{
      socket: socket,
      sequence_numbers_for_universes: %{}
    }

    {:ok, state}
  end

  def send_packet(data) do
    GenServer.cast(__MODULE__, {:send_packet, data})
  end

  def handle_cast({:send_packet, data}, %{socket: socket, sequence_numbers_for_universes: sequence_numbers_for_universes} = state) do

    updated_universes = Enum.map(@universe_configuration, fn universe_number ->
      previous_sequence_number = Access.get(sequence_numbers_for_universes, universe_number) || 0
      current_sequence_number = rem(previous_sequence_number + 1, 256)
      data_for_universe = Access.get(data, universe_number) || []

      packet = LiveLightingControl.SACNSenderHelper.get_dmx_packet(data_for_universe, current_sequence_number, universe_number)
      ip = get_multicast_ip_for_universe(universe_number)

      :gen_udp.send(socket, ip, 5568, packet)

      {universe_number, current_sequence_number}

    end) |> Map.new()

    {:noreply, Map.put(state, :sequence_numbers_for_universes, updated_universes )}
  end

  defp get_multicast_ip_for_universe(universe_number) when universe_number in 1..63999 do
    high = div(universe_number, 256)
    low = rem(universe_number, 256)
    {239, 255, high, low}
  end

  def terminate(_reason, %{socket: socket}) do
    :gen_udp.close(socket)
  end
end
