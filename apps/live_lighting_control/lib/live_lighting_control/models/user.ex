defmodule LiveLightingControl.Models.User do
  alias LiveLightingControl.Models.CommonTypes

  @type t :: %__MODULE__{
          id: String.t(),
          label: String.t(),
          selected_fixture_ids: [CommonTypes.fixture_id()],
          primary_selected_fixture_id: CommonTypes.fixture_id(),
          current_page_index: number()
        }

  defstruct id: nil,
            label: nil,
            selected_fixture_ids: [],
            primary_selected_fixture_id: nil,
            current_page_index: 0
end
