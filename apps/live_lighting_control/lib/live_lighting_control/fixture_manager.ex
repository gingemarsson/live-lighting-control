defmodule LiveLightingControl.FixtureManager do
  use GenServer

  alias LiveLightingControl.Fixture
  alias LiveLightingControl.FixtureType
  alias LiveLightingControl.FixtureTypeChannel
  alias LiveLightingControl.FixtureGroup
  alias LiveLightingControl.CommonTypes

  alias UUID

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec get_fixtures_map() :: %{CommonTypes.fixture_id() => LiveLightingControl.Fixture.t()}
  def get_fixtures_map do
    GenServer.call(__MODULE__, :get_fixtures_map)
  end

  @spec get_fixture_types_map() :: %{
          CommonTypes.fixture_type_id() => LiveLightingControl.FixtureType.t()
        }
  def get_fixture_types_map do
    GenServer.call(__MODULE__, :get_fixture_types_map)
  end

  @spec get_fixture_groups_map() :: %{
          CommonTypes.fixture_type_id() => LiveLightingControl.FixtureType.t()
        }
  def get_fixture_groups_map do
    GenServer.call(__MODULE__, :get_fixture_groups_map)
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    dimmer_fixturetype_id = UUID.uuid4()
    rgb_fixturetype_id = UUID.uuid4()
    sixpar_300_fixturetype_id = UUID.uuid4()

    fixture_types = [
      %FixtureType{
        id: dimmer_fixturetype_id,
        label: "Dimmer",
        channels: [
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "dimmer",
            dmx_address: 0,
            type: :dimmer
          }
        ]
      },
      %FixtureType{
        id: rgb_fixturetype_id,
        label: "Dimmer",
        channels: [
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "dimmer",
            dmx_address: 0,
            type: :dimmer
          },
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "red",
            dmx_address: 1,
            type: :color_red
          },
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "green",
            dmx_address: 2,
            type: :color_green
          },
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "blue",
            dmx_address: 3,
            type: :color_blue
          },
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "strobe",
            dmx_address: 4,
            type: :strobe,
            default_value: 50
          }
        ]
      },
      %FixtureType{
        id: sixpar_300_fixturetype_id,
        label: "Elation SixPar 300 (8ch)",
        channels: [
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "red",
            dmx_address: 0,
            type: :color_red
          },
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "green",
            dmx_address: 1,
            type: :color_green
          },
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "blue",
            dmx_address: 2,
            type: :color_blue
          },
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "white",
            dmx_address: 3,
            type: :color_white
          },
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "amber",
            dmx_address: 4,
            type: :color_amber
          },
          %FixtureTypeChannel{id: UUID.uuid4(), attribute: "uv", dmx_address: 5, type: :color_uv},
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "dimmer",
            dmx_address: 6,
            type: :dimmer
          },
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "strobe",
            dmx_address: 7,
            type: :strobe
          }
        ]
      }
    ]

    fixtures =
      [
        %Fixture{
          id: "1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a",
          label: "Dimmer 1",
          dmx_address: 1,
          universe: 1,
          fixture_type_id: dimmer_fixturetype_id
        },
        %Fixture{
          id: "83e98c74-c272-42db-91b0-d4ce6adb4c90",
          label: "Dimmer 2",
          dmx_address: 2,
          universe: 1,
          fixture_type_id: dimmer_fixturetype_id
        },
        %Fixture{
          id: "15867280-3f56-4824-a56c-5059b16b183b",
          label: "Dimmer 3",
          dmx_address: 3,
          universe: 1,
          fixture_type_id: dimmer_fixturetype_id
        },
        %Fixture{
          id: "34562280-3f56-4824-a56c-5059b16b183b",
          label: "Dimmer 4",
          dmx_address: 4,
          universe: 1,
          fixture_type_id: dimmer_fixturetype_id
        }
      ] ++
        Enum.map(5..32, fn i ->
          %Fixture{
            id: UUID.uuid4(),
            label: "Dimmer #{i}",
            dmx_address: i,
            universe: 1,
            fixture_type_id: dimmer_fixturetype_id
          }
        end) ++
        [
          %Fixture{
            id: UUID.uuid4(),
            label: "Tourled 1",
            dmx_address: 210,
            universe: 1,
            fixture_type_id: rgb_fixturetype_id
          },
          %Fixture{
            id: UUID.uuid4(),
            label: "Tourled 2",
            dmx_address: 215,
            universe: 1,
            fixture_type_id: rgb_fixturetype_id
          },
          %Fixture{
            id: UUID.uuid4(),
            label: "Tourled 3",
            dmx_address: 220,
            universe: 1,
            fixture_type_id: rgb_fixturetype_id
          },
          %Fixture{
            id: "687eb125-ba48-4000-a088-f8c5d5919baf",
            label: "SixPar 1",
            dmx_address: 424,
            universe: 1,
            fixture_type_id: sixpar_300_fixturetype_id
          },
          %Fixture{
            id: "2e647c7b-d068-440f-905f-6e13b2ab2f61",
            label: "SixPar 2",
            dmx_address: 432,
            universe: 1,
            fixture_type_id: sixpar_300_fixturetype_id
          },
          %Fixture{
            id: "3f647c7b-d068-440f-905f-6e13b2ab2f62",
            label: "SixPar 3",
            dmx_address: 440,
            universe: 1,
            fixture_type_id: sixpar_300_fixturetype_id
          },
          %Fixture{
            id: "4f647c7b-d068-440f-905f-6e13b2ab2f63",
            label: "SixPar 4",
            dmx_address: 448,
            universe: 1,
            fixture_type_id: sixpar_300_fixturetype_id
          },
          %Fixture{
            id: "5f647c7b-d068-440f-905f-6e13b2ab2f64",
            label: "SixPar 5",
            dmx_address: 456,
            universe: 1,
            fixture_type_id: sixpar_300_fixturetype_id
          },
          %Fixture{
            id: "6f647c7b-d068-440f-905f-6e13b2ab2f65",
            label: "SixPar 6",
            dmx_address: 464,
            universe: 1,
            fixture_type_id: sixpar_300_fixturetype_id
          },
          %Fixture{
            id: "7f647c7b-d068-440f-905f-6e13b2ab2f66",
            label: "SixPar 7",
            dmx_address: 472,
            universe: 1,
            fixture_type_id: sixpar_300_fixturetype_id
          },
          %Fixture{
            id: "8f647c7b-d068-440f-905f-6e13b2ab2f67",
            label: "SixPar 8",
            dmx_address: 480,
            universe: 1,
            fixture_type_id: sixpar_300_fixturetype_id
          }
        ]

    sixpar_ids =
      fixtures
      |> Enum.filter(fn fixture -> String.starts_with?(fixture.label, "SixPar") end)
      |> Enum.map(& &1.id)

    dimmer_ids =
      fixtures
      |> Enum.filter(fn fixture -> String.starts_with?(fixture.label, "Dimmer") end)
      |> Enum.map(& &1.id)

    fixture_groups = [
      %FixtureGroup{
        id: UUID.uuid4(),
        label: "Dimmers",
        fixture_ids: dimmer_ids
      },
      %FixtureGroup{
        id: UUID.uuid4(),
        label: "SixPars",
        fixture_ids: sixpar_ids
      }
    ]

    state = %{
      fixtures: Map.new(fixtures, &{&1.id, &1}),
      fixture_types: Map.new(fixture_types, &{&1.id, &1}),
      fixture_groups: Map.new(fixture_groups, &{&1.id, &1})
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_fixtures_map, _from, state) do
    {:reply, state.fixtures, state}
  end

  @impl true
  def handle_call(:get_fixture_types_map, _from, state) do
    {:reply, state.fixture_types, state}
  end

  @impl true
  def handle_call(:get_fixture_groups_map, _from, state) do
    {:reply, state.fixture_groups, state}
  end
end
