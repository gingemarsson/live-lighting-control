defmodule LiveLightingControl.FixtureManager do
  use GenServer

  alias LiveLightingControl.Fixture
  alias LiveLightingControl.FixtureType
  alias LiveLightingControl.FixtureTypeChannel

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_fixtures do
    GenServer.call(__MODULE__, :get_fixtures)
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
          %FixtureTypeChannel{id: UUID.uuid4(), channel_function_key: "dimmer", dmx_address: 1, type: :dimmer}
        ]
      },
      %FixtureType{
        id: rgb_fixturetype_id,
        label: "Dimmer",
        channels: [
          %FixtureTypeChannel{id: UUID.uuid4(), channel_function_key: "dimmer", dmx_address: 1, type: :dimmer},
          %FixtureTypeChannel{id: UUID.uuid4(), channel_function_key: "red", dmx_address: 1, type: :color_red},
          %FixtureTypeChannel{
            id: UUID.uuid4(),
            channel_function_key: "green",
            dmx_address: 1,
            type: :color_green
          },
          %FixtureTypeChannel{id: UUID.uuid4(), channel_function_key: "blue", dmx_address: 1, type: :color_blue}
        ]
      }
    ]

    fixtures = [
      %Fixture{
        id: "1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a",
        label: "Dimmer 1",
        dmx_address: 1,
        fixtureTypeId: dimmer_fixturetype_id
      },
      %Fixture{
        id: "83e98c74-c272-42db-91b0-d4ce6adb4c90",
        label: "Dimmer 2",
        dmx_address: 2,
        fixtureTypeId: dimmer_fixturetype_id
      },
      %Fixture{
        id: "15867280-3f56-4824-a56c-5059b16b183b",
        label: "Dimmer 3",
        dmx_address: 3,
        fixtureTypeId: dimmer_fixturetype_id
      },
      %Fixture{
        id: UUID.uuid4(),
        label: "Dimmer 4",
        dmx_address: 4,
        fixtureTypeId: dimmer_fixturetype_id
      },
      %Fixture{
        id: UUID.uuid4(),
        label: "Dimmer 5",
        dmx_address: 5,
        fixtureTypeId: dimmer_fixturetype_id
      },
      %Fixture{
        id: UUID.uuid4(),
        label: "Tourled 1",
        dmx_address: 10,
        fixtureTypeId: rgb_fixturetype_id
      },
      %Fixture{
        id: UUID.uuid4(),
        label: "Tourled 2",
        dmx_address: 14,
        fixtureTypeId: rgb_fixturetype_id
      },
      %Fixture{
        id: UUID.uuid4(),
        label: "Tourled 3",
        dmx_address: 18,
        fixtureTypeId: rgb_fixturetype_id
      }
    ]

    state = %{
      fixtures: Map.new(fixtures, &{&1.id, &1}),
      fixture_types: Map.new(fixtureTypes, &{&1.id, &1})
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_fixtures, _from, state) do
    {:reply, Map.values(state.fixtures), state}
  end
end
