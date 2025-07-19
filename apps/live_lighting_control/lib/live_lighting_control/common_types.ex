defmodule LiveLightingControl.CommonTypes do
  @typedoc "Fixture id, a UUID"
  @type fixture_id :: String.t()

  @typedoc "Fixture Type id, a UUID"
  @type fixture_type_id :: String.t()

  @typedoc "Fixture Type Channel id, a UUID"
  @type fixture_type_channel_id :: String.t()

  @typedoc "Attribute id, a UUID"
  @type attribute_id :: String.t()

  @typedoc "A single attribute value for a fixture (e.g., dimmer level, color, etc.). Typically an integer between 0 and 255."
  @type attribute_value :: integer()

  @typedoc "A map of attribute IDs (strings) to their corresponding values for a single fixture."
  @type attribute_map :: %{attribute_id() => attribute_value()}

  @typedoc "A map of fixture IDs (UUID strings) to their attribute maps."
  @type fixture_attribute_map :: %{fixture_id() => attribute_map()}
end
