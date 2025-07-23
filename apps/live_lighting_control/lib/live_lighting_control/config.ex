defmodule LiveLightingControl.Config do
  @type t :: %__MODULE__{
          enable_programmer: boolean(),
          enable_scenes: boolean(),
          enable_sacn_output: boolean(),
          blackout: boolean(),
          main_master: float()
        }

  defstruct enable_programmer: nil,
            enable_scenes: nil,
            enable_sacn_output: nil,
            blackout: nil,
            main_master: nil
end
