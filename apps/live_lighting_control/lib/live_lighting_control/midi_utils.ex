defmodule LiveLightingControl.MidiUtils do

  # Note: This is currently hardcoded for AKAI APC mini MK2
  def get_executor_position_from_midi(midi_position) do
    pos = cond do
      midi_position >= 48 and midi_position <= 55 -> %{row_number: 0, executor_number: midi_position - 47} # Sliders
      midi_position >= 100 and midi_position <= 1007 -> %{row_number: 0, executor_number: midi_position - 99} # Slider buttons
      midi_position >= 0 and midi_position <= 31 ->  %{row_number: div(31 - midi_position, 8) + 1, executor_number: rem(midi_position, 8) + 1} # Flash buttons
      true -> %{row_number: 1, executor_number: 1}
    end

    IO.puts(inspect(pos))

    pos
  end

  def get_value_from_midi_value(midi_value) do
    round(midi_value / 1.27)
  end

  def get_action_from_midi_status(status) when status in 0x80..0x8F, do: :button_up
  def get_action_from_midi_status(status) when status in 0x90..0x9F, do: :button_down
  def get_action_from_midi_status(status) when status in 0xB0..0xBF, do: :slider_change
  def get_action_from_midi_status(_), do: :unknown
end
