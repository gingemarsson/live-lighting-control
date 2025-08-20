defmodule LiveLightingControl.Models.ActiveEntity do
  @type t :: %__MODULE__{
          id: String.t(),
          type: atom(),
          scene_id: String.t(),
          cue_id: String.t(),
          fade_in_triggered_time: number(),
          fade_out_triggered_time: number(),
          fade_in_completed_time: number(),
          fade_out_completed_time: number()
        }

  @derive Jason.Encoder
  defstruct id: nil,
            type: nil,
            scene_id: nil,
            cue_id: nil,
            fade_in_triggered_time: nil,
            fade_out_triggered_time: nil,
            fade_in_completed_time: nil,
            fade_out_completed_time: nil
end
