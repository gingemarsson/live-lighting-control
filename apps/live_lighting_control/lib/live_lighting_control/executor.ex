defmodule LiveLightingControl.ExecutorPage do
  alias LiveLightingControl.Executor

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          # Note: Always 5 rows, top row contains faders, rest 1-4 are buttons. Each row has 8 elements.
          executors: [[Executor.t()]]
        }

  defstruct id: nil,
            label: nil,
            executors: nil,
            executor_buttons: nil
end

defmodule LiveLightingControl.Executor do
  @type executor_state_map :: %{:active => boolean()}

  @type t :: %__MODULE__{
          id: String.t(),
          type: atom(),
          button_type: atom(),
          entity_id: String.t(),
          state: executor_state_map()
        }

  defstruct id: nil,
            type: nil,
            button_type: nil,
            entity_id: nil,
            state: nil
end
