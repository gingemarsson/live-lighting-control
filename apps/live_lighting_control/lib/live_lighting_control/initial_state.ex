defmodule LiveLightingControl.InitialState do
  require UUID

  alias LiveLightingControl.Models.Card
  alias LiveLightingControl.Models.Cue
  alias LiveLightingControl.Models.Executor
  alias LiveLightingControl.Models.ExecutorPage
  alias LiveLightingControl.Models.Fixture
  alias LiveLightingControl.Models.FixtureGroup
  alias LiveLightingControl.Models.FixtureType
  alias LiveLightingControl.Models.FixtureTypeChannel
  alias LiveLightingControl.Models.Layout
  alias LiveLightingControl.Models.Scene
  alias LiveLightingControl.Models.State
  alias LiveLightingControl.Models.View
  alias LiveLightingControl.Models.User

  def get_initial_state do
    config = %{
      enable_programmer: true,
      enable_scenes: true,
      enable_sacn_output: false,
      blackout: false,
      main_master: 255
    }

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
        id: get_new_guid(),
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

    executor_pages = [
      %ExecutorPage{
        id: "07c82518-62dc-4ddc-8db9-2c745f0a2f10",
        label: "Page 1",
        executors: [
          [
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "69ac89df-fdaf-481d-9788-d522a159a465",
              button_type: :go
            },
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "4b17863d-99f3-4ce9-bacb-e9e3e67b9b31",
              button_type: :go
            },
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "7b7f7fc7-69c0-4eb2-86a5-22fa8e2d1144",
              button_type: :go
            },
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "00d0b87a-c9f7-4727-84a7-841f15c9fcae",
              button_type: :go
            },
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "683d4473-7c32-4eba-ae23-1f0229078301",
              button_type: :next
            }
          ],
          [
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "69ac89df-fdaf-481d-9788-d522a159a465",
              button_type: :flash
            },
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "4b17863d-99f3-4ce9-bacb-e9e3e67b9b31",
              button_type: :flash
            },
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "7b7f7fc7-69c0-4eb2-86a5-22fa8e2d1144",
              button_type: :flash
            },
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "00d0b87a-c9f7-4727-84a7-841f15c9fcae",
              button_type: :flash
            }
          ],
          [],
          [
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "683d4473-7c32-4eba-ae23-1f0229078301",
              button_type: :next
            },
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "683d4473-7c32-4eba-ae23-1f0229078301",
              button_type: :previous
            }
          ],
          []
        ]
      },
      %ExecutorPage{
        id: "17c82518-62dc-4ddc-8db9-2c745f0a2f10",
        label: "Page 2",
        executors: [
          [
            %Executor{
              id: get_new_guid(),
              type: :scene,
              entity_id: "69ac89df-fdaf-481d-9788-d522a159a465",
              button_type: :flash
            }
          ],
          [],
          [],
          [],
          []
        ]
      }
    ]

    dimmer_fixturetype_id = get_new_guid()
    rgb_fixturetype_id = get_new_guid()
    sixpar_300_fixturetype_id = get_new_guid()

    fixture_types = [
      %FixtureType{
        id: dimmer_fixturetype_id,
        label: "Dimmer",
        channels: [
          %FixtureTypeChannel{
            id: get_new_guid(),
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
            id: get_new_guid(),
            attribute: "dimmer",
            dmx_address: 0,
            type: :dimmer
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
            attribute: "red",
            dmx_address: 1,
            type: :color_red
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
            attribute: "green",
            dmx_address: 2,
            type: :color_green
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
            attribute: "blue",
            dmx_address: 3,
            type: :color_blue
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
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
            id: get_new_guid(),
            attribute: "red",
            dmx_address: 0,
            type: :color_red
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
            attribute: "green",
            dmx_address: 1,
            type: :color_green
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
            attribute: "blue",
            dmx_address: 2,
            type: :color_blue
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
            attribute: "white",
            dmx_address: 3,
            type: :color_white
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
            attribute: "amber",
            dmx_address: 4,
            type: :color_amber
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
            attribute: "uv",
            dmx_address: 5,
            type: :color_uv
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
            attribute: "dimmer",
            dmx_address: 6,
            type: :dimmer
          },
          %FixtureTypeChannel{
            id: get_new_guid(),
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
            id: get_new_guid(),
            label: "Dimmer #{i}",
            dmx_address: i,
            universe: 1,
            fixture_type_id: dimmer_fixturetype_id
          }
        end) ++
        [
          %Fixture{
            id: get_new_guid(),
            label: "Tourled 1",
            dmx_address: 210,
            universe: 1,
            fixture_type_id: rgb_fixturetype_id
          },
          %Fixture{
            id: get_new_guid(),
            label: "Tourled 2",
            dmx_address: 215,
            universe: 1,
            fixture_type_id: rgb_fixturetype_id
          },
          %Fixture{
            id: get_new_guid(),
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
        id: get_new_guid(),
        label: "Dimmers",
        fixture_ids: dimmer_ids
      },
      %FixtureGroup{
        id: get_new_guid(),
        label: "SixPars",
        fixture_ids: sixpar_ids
      }
    ]

    scenes = [
      %Scene{
        id: "69ac89df-fdaf-481d-9788-d522a159a465",
        label: "Moody",
        cues: [
          %Cue{
            id: "6ef55585-5222-48f6-beec-412f714ad697",
            label: "Cue 1",
            fixture_attribute_map: %{"1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a" => %{"dimmer" => 255}},
            state: %{triggered_time: 0, fade_completed_time: 0}
          }
        ],
        state: %{master: 90, cue_index: 0}
      },
      %Scene{
        id: "4b17863d-99f3-4ce9-bacb-e9e3e67b9b31",
        label: "Party",
        cues: [
          %Cue{
            id: "a971dd1b-755e-4df7-ac7d-4d054b46792a",
            label: "Cue 1",
            fixture_attribute_map: %{"83e98c74-c272-42db-91b0-d4ce6adb4c90" => %{"dimmer" => 255}},
            state: %{triggered_time: 0, fade_completed_time: 0}
          }
        ],
        state: %{master: 90, cue_index: 0}
      },
      %Scene{
        id: "7b7f7fc7-69c0-4eb2-86a5-22fa8e2d1144",
        label: "Relax",
        cues: [
          %Cue{
            id: "33efb147-de4d-4e9a-b4dd-0a7dc58d87d2",
            label: "Cue 1",
            fixture_attribute_map: %{"15867280-3f56-4824-a56c-5059b16b183b" => %{"dimmer" => 255}},
            state: %{triggered_time: 0, fade_completed_time: 0}
          }
        ],
        state: %{master: 90, cue_index: 0}
      },
      %Scene{
        id: "00d0b87a-c9f7-4727-84a7-841f15c9fcae",
        label: "All lights",
        cues: [
          %Cue{
            id: "0187c872-bed4-49de-8fd0-31c2a2981550",
            label: "Cue 1",
            fixture_attribute_map: %{
              "1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a" => %{"dimmer" => 255},
              "83e98c74-c272-42db-91b0-d4ce6adb4c90" => %{"dimmer" => 255},
              "15867280-3f56-4824-a56c-5059b16b183b" => %{"dimmer" => 255}
            },
            state: %{triggered_time: 0, fade_completed_time: 0}
          }
        ],
        state: %{master: 90, cue_index: 0}
      },
      %Scene{
        id: "683d4473-7c32-4eba-ae23-1f0229078301",
        label: "Cues",
        cues: [
          %Cue{
            id: "472446e6-6f4e-42a2-947d-3750a60bc78d",
            label: "Cue 1",
            fixture_attribute_map: %{
              "1c06d0c8-5eb5-4a1c-9e6c-f9df2ee68f8a" => %{"dimmer" => 255}
            },
            state: %{triggered_time: 0, fade_completed_time: 0}
          },
          %Cue{
            id: "871e5c65-0413-4a4b-a4fc-3cca6c14e9e4",
            label: "Cue 2",
            fixture_attribute_map: %{
              "83e98c74-c272-42db-91b0-d4ce6adb4c90" => %{"dimmer" => 255}
            },
            state: %{triggered_time: 0, fade_completed_time: 0}
          },
          %Cue{
            id: "16e0345c-1eef-45da-acb0-ad9b48ac188b",
            label: "Cue 3",
            fixture_attribute_map: %{
              "15867280-3f56-4824-a56c-5059b16b183b" => %{"dimmer" => 255}
            },
            state: %{triggered_time: 0, fade_completed_time: 0}
          }
        ],
        state: %{master: 90, cue_index: 0}
      }
    ]

    views = [
      %View{
        id: "07c82518-62dc-4ddc-8db9-2c745f0a2f10",
        label: "Default View",
        cards: [
          %Card{id: get_new_guid(), type: :config, configuration: %{}},
          %Card{id: get_new_guid(), type: :fixture_groups, configuration: %{}},
          %Card{id: get_new_guid(), type: :fixtures, configuration: %{}},
          %Card{id: get_new_guid(), type: :layouts, configuration: %{}},
          %Card{id: get_new_guid(), type: :programmer, configuration: %{}},
          %Card{id: get_new_guid(), type: :output, configuration: %{}},
          %Card{id: get_new_guid(), type: :scenes, configuration: %{}}
        ]
      },
      %View{
        id: "abaa628c-c33e-4082-908c-7afa19f4970c",
        label: "Select fixtures",
        cards: [
          %Card{id: get_new_guid(), type: :config, configuration: %{}},
          %Card{id: get_new_guid(), type: :fixture_groups, configuration: %{}},
          %Card{id: get_new_guid(), type: :fixtures, configuration: %{}},
          %Card{id: get_new_guid(), type: :selected_fixtures, configuration: %{}}
        ]
      },
      %View{
        id: "a7114549-d9db-444c-9249-ed635869f3d3",
        label: "Programmer",
        cards: [
          %Card{id: get_new_guid(), type: :config, configuration: %{}},
          %Card{id: get_new_guid(), type: :fixture_groups, configuration: %{}},
          %Card{id: get_new_guid(), type: :programmer, configuration: %{}},
          %Card{id: get_new_guid(), type: :output, configuration: %{}}
        ]
      }
    ]

    users = [
      %User{
        id: "5db04ee7-9bc4-43f3-9ac1-e0f2b8bb9f6f",
        label: "User A"
      },
      %User{
        id: "3c1499f0-32ba-430e-81f9-f808eb999209",
        label: "User B"
      }
    ]

    state = %State{
      config: config,
      programmer: %{},
      scenes: scenes,
      layouts: layouts,
      fixtures: fixtures,
      fixture_types: fixture_types,
      fixture_groups: fixture_groups,
      executor_pages: executor_pages,
      views: views,
      users: users
    }

    state
  end

  defp get_new_guid do
    UUID.uuid4()
  end
end
