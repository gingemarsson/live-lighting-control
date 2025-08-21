defmodule LiveLightingControl.Schema.StoredShowFile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "show_file" do
    field :name, :string
    field :json, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :json])
    |> validate_required([:name])
    |> validate_required([:json])
  end
end
