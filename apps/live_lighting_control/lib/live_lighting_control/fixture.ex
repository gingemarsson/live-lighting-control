defmodule LiveLightingControl.Fixture do
  defstruct id: nil,
            label: nil,
            universe: nil,
            dmx_address: nil,
            fixtureTypeId: nil
end

defmodule LiveLightingControl.FixtureType do
  defstruct id: nil,
            label: nil,
            channels: nil
end


defmodule LiveLightingControl.FixtureTypeChannel do
  defstruct id: nil,
            channel_function_key: nil,
            dmx_address: nil,
            type: nil
end
