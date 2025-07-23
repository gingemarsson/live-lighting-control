defmodule LiveLightingControl.MidiUtils do
  # Note: This is currently hardcoded for AKAI APC mini MK2
  def get_executor_position_or_command_from_midi(midi_position, action) do
    cond do
      ### Executors
      #

      # Sliders
      midi_position >= 48 and midi_position <= 55 and action == :slider_change ->
        %{type: :executor_position, row_number: 0, executor_number: midi_position - 47}

      # Slider buttons
      midi_position >= 100 and midi_position <= 107 ->
        %{type: :executor_position, row_number: 0, executor_number: midi_position - 99}

      # Flash buttons
      midi_position >= 0 and midi_position <= 31 ->
        %{
          type: :executor_position,
          row_number: div(31 - midi_position, 8) + 1,
          executor_number: rem(midi_position, 8) + 1
        }

      ### Actions
      #

      # Toggle sACN output
      midi_position == 112 ->
        %{type: :command, command: :toggle_sacn_output}

      # Toggle programmer
      midi_position == 113 ->
        %{type: :command, command: :toggle_programmer}

      # Page up
      midi_position == 118 ->
        %{type: :command, command: :page_up}

      # Page down
      midi_position == 119 ->
        %{type: :command, command: :page_down}

      # Blackout toggle
      midi_position == 122 ->
        %{type: :command, command: :toggle_blackout}

      # Main master (fader)
      midi_position == 56 ->
        %{type: :command, command: :main_master}

      true ->
        nil
    end
  end

  def get_value_from_midi_value(midi_value) do
    round(midi_value / 1.27 * 2.55)
  end

  def get_action_from_midi_status(status) when status in 0x80..0x8F, do: :button_up
  def get_action_from_midi_status(status) when status in 0x90..0x9F, do: :button_down
  def get_action_from_midi_status(status) when status in 0xB0..0xBF, do: :slider_change
  def get_action_from_midi_status(_), do: :unknown
end
