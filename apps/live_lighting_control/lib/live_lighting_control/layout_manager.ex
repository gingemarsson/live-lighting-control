defmodule LiveLightingControl.LayoutManager do
  use GenServer

  alias LiveLightingControl.Layout

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec get_layouts() :: [Layout.t()]
  def get_layouts do
    GenServer.call(__MODULE__, :get_layouts)
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    layouts = [
      %Layout{
        id: "687eb125-ba48-8000-a088-f8c5d5919baf",
        label: "Front Stage Layout",
        fixtures: %{
          "1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a" => %{x: 0, y: 0, label: "✨"},
          "83e98c74-c272-42db-91b0-d4ce6adb4c90" => %{x: 0, y: 100, label: "✨"},
          "15867280-3f56-4824-a56c-5059b16b183b" => %{x: 100, y: 0, label: "✨"},
          "34562280-3f56-4824-a56c-5059b16b183b" => %{x: 100, y: 100, label: "✨"}
        }
      },
      %Layout{
        id: "2e647c7b-d068-440f-905f-6e13b2ab2f61",
        label: "Diagonal Spread",
        fixtures: %{
          "1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a" => %{x: 10, y: 10, label: "■"},
          "83e98c74-c272-42db-91b0-d4ce6adb4c90" => %{x: 30, y: 30, label: "■"},
          "15867280-3f56-4824-a56c-5059b16b183b" => %{x: 60, y: 60, label: "▲"},
          "34562280-3f56-4824-a56c-5059b16b183b" => %{x: 90, y: 90, label: "▲"}
        }
      },
      %Layout{
        id: UUID.uuid4(),
        label: "SixPars Vertical Rows",
        fixtures: %{
          "687eb125-ba48-4000-a088-f8c5d5919baf" => %{x: 20, y: 20, label: "SixPar 1"},
          "3f647c7b-d068-440f-905f-6e13b2ab2f62" => %{x: 20, y: 40, label: "SixPar 3"},
          "5f647c7b-d068-440f-905f-6e13b2ab2f64" => %{x: 20, y: 60, label: "SixPar 5"},
          "7f647c7b-d068-440f-905f-6e13b2ab2f66" => %{x: 20, y: 80, label: "SixPar 7"},
          "2e647c7b-d068-440f-905f-6e13b2ab2f61" => %{x: 80, y: 20, label: "SixPar 2"},
          "4f647c7b-d068-440f-905f-6e13b2ab2f63" => %{x: 80, y: 40, label: "SixPar 4"},
          "6f647c7b-d068-440f-905f-6e13b2ab2f65" => %{x: 80, y: 60, label: "SixPar 6"},
          "8f647c7b-d068-440f-905f-6e13b2ab2f67" => %{x: 80, y: 80, label: "SixPar 8"}
        }
      }
    ]

    {:ok, Map.new(layouts, &{&1.id, &1})}
  end

  @impl true
  def handle_call(:get_layouts, _from, layouts) do
    {:reply, layouts, layouts}
  end
end
