defmodule LiveLightingControl.Models.Scene do
  alias LiveLightingControl.Models.CommonTypes
  alias LiveLightingControl.Models.Cue

  @type state_map :: %{:master => 0..100, :flash => boolean(), :cue_index => number()}

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          cues: [Cue.t()],
          state: state_map()
        }

  @derive Jason.Encoder
  defstruct id: nil,
            label: nil,
            cues: nil,
            state: nil
end

defmodule LiveLightingControl.Models.Cue do
  alias LiveLightingControl.Models.CommonTypes

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          fixture_attribute_map: CommonTypes.fixture_attribute_map()
        }

  @derive Jason.Encoder
  defstruct id: nil,
            label: nil,
            description: nil,
            fixture_attribute_map: nil
end
