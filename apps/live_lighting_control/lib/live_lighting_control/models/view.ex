defmodule LiveLightingControl.Models.View do
  alias LiveLightingControl.Models.Card

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          cards: [Card.t()]
        }

  @derive Jason.Encoder
  defstruct id: nil,
            label: nil,
            cards: nil
end

defmodule LiveLightingControl.Models.Card do
  @type t :: %__MODULE__{
          id: String.t(),
          type: atom(),
          configuration: any()
        }

  @derive Jason.Encoder
  defstruct id: nil,
            type: nil,
            configuration: nil
end
