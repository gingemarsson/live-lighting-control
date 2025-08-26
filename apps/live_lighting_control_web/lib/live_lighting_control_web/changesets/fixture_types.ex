defmodule LiveLightingControlWeb.Changeset.FixtureTypeChannel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:attribute, :string)
    field(:dmx_address, :integer)
    field(:type, :string)
    field(:default_value, :integer)
  end

  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:id, :attribute, :dmx_address, :type, :default_value])
    |> validate_required([:attribute, :dmx_address, :type])
  end
end

defmodule LiveLightingControlWeb.Changeset.FixtureType do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:label, :string)
    embeds_many(:channels, LiveLightingControlWeb.Changeset.FixtureTypeChannel)
  end

  def changeset(fixture_type, attrs) do
    fixture_type
    |> cast(attrs, [:id, :label])
    |> validate_required([:label])
    |> cast_embed(:channels)
  end
end

defmodule LiveLightingControlWeb.Changeset.Converter do
  alias LiveLightingControl.Models
  alias LiveLightingControlWeb.Changeset

  def fixture_type_to_changeset(%Models.FixtureType{} = ft) do
    attrs = %{
      "id" => ft.id,
      "label" => ft.label,
      "channels" =>
        Enum.map(ft.channels || [], fn ch ->
          %{
            "id" => ch.id,
            "attribute" => ch.attribute,
            "dmx_address" => ch.dmx_address,
            # ensure string
            "type" => to_string(ch.type),
            "default_value" => ch.default_value
          }
        end)
    }

    Changeset.FixtureType.changeset(%Changeset.FixtureType{}, attrs)
  end

   # Convert a valid FixtureType changeset to plain model
   def changeset_to_model(%Ecto.Changeset{valid?: true, changes: changes}) do

    %Models.FixtureType{
      id: changes[:id],
      label: changes[:label],
      channels: channels_to_model(changes[:channels] || [])
    }
  end

  # Convert embedded channels
  defp channels_to_model(channels) do
    Enum.map(channels, fn
      %Ecto.Changeset{changes: ch_changes} ->
        %Models.FixtureTypeChannel{
          id: ch_changes[:id],
          attribute: ch_changes[:attribute],
          dmx_address: ch_changes[:dmx_address],
          type: ch_changes[:type],
          default_value: ch_changes[:default_value]
        }
    end)
  end
end
