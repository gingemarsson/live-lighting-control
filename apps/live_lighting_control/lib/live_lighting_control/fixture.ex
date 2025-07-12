defmodule LiveLightingControl.Fixture do
  defstruct id: nil,
            label: nil,
            universe: nil,
            dmx_address: nil,
            fixture_type_id: nil
end

defmodule LiveLightingControl.FixtureType do
  defstruct id: nil,
            label: nil,
            channels: nil
end


defmodule LiveLightingControl.FixtureTypeChannel do
  defstruct id: nil,
            attribute: nil,
            dmx_address: nil,
            type: nil,
            default_value: 0
end
