defmodule LiveLightingControl.SACNSenderHelper do
  import Bitwise

  @port 5568
  @priority 100
  @cid <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15>> # Unique sender CID
  @source_name "Live Lighting Control sACN"

  def get_dmx_packet(dmx_values, sequence_number, universe_number) when is_list(dmx_values) and length(dmx_values) <= 512 do
    # Pad DMX values to 512 bytes
    dmx_data =
      dmx_values
      |> Enum.map(&max(min(&1, 255), 0))
      |> Enum.map(&trunc/1)
      |> :binary.list_to_bin()
      |> pad_to_512()

    packet = build_packet(dmx_data, sequence_number, universe_number)

    packet
  end

  defp pad_to_512(data) when byte_size(data) < 512 do
    data <> :binary.copy(<<0>>, 512 - byte_size(data))
  end

  defp pad_to_512(data), do: data

  defp build_packet(dmx_data, sequence_number, universe_number) do
    # Root Layer
    preamble_size = <<0x00, 0x10>>
    postamble_size = <<0x00, 0x00>>
    acn_pid = "ASC-E1.17\0\0\0"
    # Flags & Length: 0x7000 OR length of the remainder
    root_flength = 0x7000 ||| (0x16 + 0x38 + 0x0b + byte_size(dmx_data))
    root_flags_length = <<(root_flength >>> 8) &&& 0xFF, root_flength &&& 0xFF>>

    vector_root = <<0x00, 0x00, 0x00, 0x04>>

    # Framing Layer
    framing_length = 0x7000 ||| (0x38 + 0x0b + byte_size(dmx_data))
    framing_flags_length = <<(framing_length >>> 8) &&& 0xFF, framing_length &&& 0xFF>>

    vector_framing = <<0x00, 0x00, 0x00, 0x02>>

    source_name = pad_to_64(@source_name)

    universe = <<(div(universe_number, 256)), rem(universe_number, 256)>>

    # DMP Layer
    dmp_length = 0x7000 ||| (0x0b + byte_size(dmx_data))
    dmp_flags_length = <<(dmp_length >>> 8) &&& 0xFF, dmp_length &&& 0xFF>>

    # DMP Header
    dmp_header = <<
      0x02,       # DMP Vector
      0xA1,       # Address Type & Data Type
      0x00, 0x00, # First Property Address
      0x00, 0x01, # Address Increment
      0x02       # Property value count MSB: 512+1 = 513
    >> <> <<rem(513, 256)>>

    # DMX Data (starts with 0 as start code)
    dmp_data = <<0>> <> dmx_data

    <<
      # Root Layer
      preamble_size::binary,
      postamble_size::binary,
      acn_pid::binary,
      root_flags_length::binary,
      vector_root::binary,
      @cid::binary,

      # Framing Layer
      framing_flags_length::binary,
      vector_framing::binary,
      source_name::binary,
      <<@priority>>,
      <<0,0>>,   # Reserved
      <<sequence_number>>,     # Sequence
      <<0>>,     # Options
      universe::binary,

      # DMP Layer
      dmp_flags_length::binary,
      dmp_header::binary,
      dmp_data::binary
    >>
  end

  defp pad_to_64(str) when byte_size(str) < 64 do
    str <> :binary.copy(<<0>>, 64 - byte_size(str))
  end

  defp pad_to_64(str), do: binary_part(str, 0, 64)
end
