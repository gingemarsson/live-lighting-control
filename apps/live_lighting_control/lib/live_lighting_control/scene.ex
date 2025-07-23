defmodule LiveLightingControl.Scene do
  alias LiveLightingControl.CommonTypes

  @type state_map :: %{:master => 0..100, :flash => boolean()}

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          description: String.t(),
          fixtures: CommonTypes.fixture_attribute_map(),
          state: state_map()
        }

  defstruct id: nil,
            label: nil,
            description: nil,
            fixtures: nil,
            state: nil
end
