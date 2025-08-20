defmodule LiveLightingControl.Models.Layout do
  alias LiveLightingControl.Models.CommonTypes

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          fixtures: %{
            CommonTypes.fixture_id() => %{:x => number(), :y => number(), :label => String.t()}
          }
        }

  @derive Jason.Encoder
  defstruct id: nil,
            label: nil,
            fixtures: nil
end
