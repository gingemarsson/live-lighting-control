defmodule LiveLightingControl.ViewManager do
  use GenServer

  alias LiveLightingControl.View
  alias LiveLightingControl.Card

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec get_views() :: [View.t()]
  def get_views do
    GenServer.call(__MODULE__, :get_views)
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    views = [
      %View{
        id: "07c82518-62dc-4ddc-8db9-2c745f0a2f10",
        label: "Default View",
        cards: [
          %Card{id: UUID.uuid4(), type: :config, configuration: %{}},
          %Card{id: UUID.uuid4(), type: :fixture_groups, configuration: %{}},
          %Card{id: UUID.uuid4(), type: :fixtures, configuration: %{}},
          %Card{id: UUID.uuid4(), type: :layouts, configuration: %{}},
          %Card{id: UUID.uuid4(), type: :programmer, configuration: %{}},
          %Card{id: UUID.uuid4(), type: :output, configuration: %{}},
          %Card{id: UUID.uuid4(), type: :scenes, configuration: %{}}
        ]
      },
      %View{
        id: "abaa628c-c33e-4082-908c-7afa19f4970c",
        label: "Select fixtures",
        cards: [
          %{cardid: UUID.uuid4(), type: :config, configuration: %{}},
          %{cardid: UUID.uuid4(), type: :fixture_groups, configuration: %{}},
          %{cardid: UUID.uuid4(), type: :fixtures, configuration: %{}},
          %{cardid: UUID.uuid4(), type: :layouts, configuration: %{}},
          %{cardid: UUID.uuid4(), type: :selected_fixtures, configuration: %{}}
        ]
      },
      %View{
        id: "a7114549-d9db-444c-9249-ed635869f3d3",
        label: "Programmer",
        cards: [
          %Card{id: UUID.uuid4(), type: :config, configuration: %{}},
          %Card{id: UUID.uuid4(), type: :fixture_groups, configuration: %{}},
          %Card{id: UUID.uuid4(), type: :programmer, configuration: %{}},
          %Card{id: UUID.uuid4(), type: :output, configuration: %{}}
        ]
      }
    ]

    {:ok, Map.new(views, &{&1.id, &1})}
  end

  @impl true
  def handle_call(:get_views, _from, views) do
    {:reply, views, views}
  end
end
