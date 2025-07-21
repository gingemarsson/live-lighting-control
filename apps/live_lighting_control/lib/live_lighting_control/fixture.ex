defmodule LiveLightingControl.FixtureTypeChannel do
  alias LiveLightingControl.CommonTypes

  @type t :: %__MODULE__{
    id: CommonTypes.fixture_type_channel_id(),
    attribute: CommonTypes.attribute_id(),
    dmx_address: integer(),
    type: String.t(),
    default_value: 0..255
  }

  defstruct id: nil,
            attribute: nil,
            dmx_address: nil,
            type: nil,
            default_value: 0
end


defmodule LiveLightingControl.FixtureType do
  alias LiveLightingControl.FixtureTypeChannel
  alias LiveLightingControl.CommonTypes

  @type t :: %__MODULE__{
    id: CommonTypes.fixture_type_id(),
    label: String.t(),
    channels: [FixtureTypeChannel.t()]
  }

  defstruct id: nil,
            label: nil,
            channels: nil
end

defmodule LiveLightingControl.Fixture do
  alias LiveLightingControl.CommonTypes

  @type t :: %__MODULE__{
    id: CommonTypes.fixture_id(),
    label: String.t(),
    universe: integer(),
    dmx_address: integer(),
    fixture_type_id: CommonTypes.fixture_type_id()
  }
  defstruct id: nil,
            label: nil,
            universe: nil,
            dmx_address: nil,
            fixture_type_id: nil
end

defmodule LiveLightingControl.FixtureGroup do
  alias LiveLightingControl.CommonTypes

  @type t :: %__MODULE__{
    id: CommonTypes.fixture_id(),
    label: String.t(),
    fixture_ids: [CommonTypes.fixture_id()]
  }
  defstruct id: nil,
            label: nil,
            fixture_ids: nil
end
