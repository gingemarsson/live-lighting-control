defmodule LiveLightingControl.Repo.Migrations.CreateShowFiles do
  use Ecto.Migration

  def change do
    create table(:show_file) do
      add :name, :string
      add :json, :string

      timestamps()
    end

    create unique_index(:show_file, [:name])
  end
end
