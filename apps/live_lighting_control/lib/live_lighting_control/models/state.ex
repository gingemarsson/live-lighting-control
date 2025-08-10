defmodule LiveLightingControl.Models.State do
  alias LiveLightingControl.Models.ExecutorPage
  alias LiveLightingControl.Models.Fixture
  alias LiveLightingControl.Models.FixtureGroup
  alias LiveLightingControl.Models.FixtureType
  alias LiveLightingControl.Models.Layout
  alias LiveLightingControl.Models.Scene
  alias LiveLightingControl.Models.View
  alias LiveLightingControl.Models.User
  alias LiveLightingControl.Models.ActiveCue
  alias LiveLightingControl.Models.CommonTypes

  @type t :: %__MODULE__{
          config: Config.t(),
          programmer: CommonTypes.fixture_attribute_map(),
          scenes: [Scene.t()],
          layouts: [Layout.t()],
          fixtures: [Fixture.t()],
          fixture_types: [FixtureType.t()],
          fixture_groups: [FixtureGroup.t()],
          executor_pages: [ExecutorPage.t()],
          views: [View.t()],
          users: [User.t()],
          active: [ActiveCue.t()]
        }

  defstruct config: nil,
            programmer: nil,
            scenes: nil,
            layouts: nil,
            fixtures: nil,
            fixture_types: nil,
            fixture_groups: nil,
            executor_pages: nil,
            views: nil,
            users: nil,
            active: []
end
