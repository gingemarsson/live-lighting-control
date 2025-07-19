defmodule LiveLightingControl.FixtureManager do
  use GenServer

  alias LiveLightingControl.Fixture
  alias LiveLightingControl.FixtureType
  alias LiveLightingControl.FixtureTypeChannel
  alias LiveLightingControl.CommonTypes

  alias UUID

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec get_fixtures_map() :: %{CommonTypes.fixture_id() => LiveLightingControl.Fixture.t()}
  def get_fixtures_map do
    GenServer.call(__MODULE__, :get_fixtures_map)
  end

  @spec get_fixture_types_map() :: %{CommonTypes.fixture_type_id() => LiveLightingControl.FixtureType.t()}
  def get_fixture_types_map do
    GenServer.call(__MODULE__, :get_fixture_types_map)
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    dimmer_fixturetype_id = UUID.uuid4()
    rgb_fixturetype_id = UUID.uuid4()

    fixtureTypes = [
      %FixtureType{
        id: dimmer_fixturetype_id,
        label: "Dimmer",
        channels: [
          %FixtureTypeChannel{id: UUID.uuid4(), attribute: "dimmer", dmx_address: 0, type: :dimmer}
        ]
      },
      %FixtureType{
        id: rgb_fixturetype_id,
        label: "Dimmer",
        channels: [
          %FixtureTypeChannel{id: UUID.uuid4(), attribute: "dimmer", dmx_address: 0, type: :dimmer},
          %FixtureTypeChannel{id: UUID.uuid4(), attribute: "red", dmx_address: 1, type: :color_red},
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            attribute: "green",
            dmx_address: 2,
            type: :color_green
          },
          %FixtureTypeChannel{id: UUID.uuid4(), attribute: "blue", dmx_address: 3, type: :color_blue},
          %FixtureTypeChannel{id: UUID.uuid4(), attribute: "strobe", dmx_address: 4, type: :strobe, default_value: 50}
        ]
      }
    ]

    fixtures = [
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
        id: UUID.uuid4(),
        label: "Dimmer 4",
        dmx_address: 4,
        universe: 1,
        fixture_type_id: dimmer_fixturetype_id
      },
      %Fixture{
        id: UUID.uuid4(),
        label: "Dimmer 5",
        dmx_address: 5,
        universe: 1,
        fixture_type_id: dimmer_fixturetype_id
      },
      %Fixture{
        id: UUID.uuid4(),
        label: "Tourled 1",
        dmx_address: 10,
        universe: 1,
        fixture_type_id: rgb_fixturetype_id
      },
      %Fixture{
        id: UUID.uuid4(),
        label: "Tourled 2",
        dmx_address: 15,
        universe: 1,
        fixture_type_id: rgb_fixturetype_id
      },
      %Fixture{
        id: UUID.uuid4(),
        label: "Tourled 3",
        dmx_address: 20,
        universe: 1,
        fixture_type_id: rgb_fixturetype_id
      }
    ]

    state = %{
      fixtures: Map.new(fixtures, &{&1.id, &1}),
      fixture_types: Map.new(fixtureTypes, &{&1.id, &1})
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

end
