defmodule LiveLightingControl.View do
  alias LiveLightingControl.Card

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          cards: [Card.t()]
        }

  defstruct id: nil,
            label: nil,
            cards: nil
end

defmodule LiveLightingControl.Card do
  @type t :: %__MODULE__{
          id: String.t(),
          type: atom(),
          configuration: any()
        }

  defstruct id: nil,
            type: nil,
            configuration: nil
end
