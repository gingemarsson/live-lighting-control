defmodule LiveLightingControl.Layout do
  alias LiveLightingControl.CommonTypes

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          fixtures: %{CommonTypes.fixture_id() => %{:x => number(), :y => number(), :label => String.t()}}
        }

  defstruct id: nil,
            label: nil,
            fixtures: nil
end
