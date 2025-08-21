defmodule LiveLightingControl.ShowFileManager do
  def get_show_files() do
    LiveLightingControl.Repo.all(LiveLightingControl.Schema.StoredShowFile)
  end

  def upsert_show_file(name, json_data) do
    %LiveLightingControl.Schema.StoredShowFile{}
    |> LiveLightingControl.Schema.StoredShowFile.changeset(%{name: name, json: json_data})
    |> LiveLightingControl.Repo.insert(
      on_conflict: {:replace, [:json, :updated_at]},
      conflict_target: :name
    )
  end

  def insert_show_file(name, json_data) do
    %LiveLightingControl.Schema.StoredShowFile{}
    |> LiveLightingControl.Schema.StoredShowFile.changeset(%{name: name, json: json_data})
    |> LiveLightingControl.Repo.insert()
  end

  def delete_show_file(name) do
    show_file = LiveLightingControl.Repo.get_by(LiveLightingControl.Schema.StoredShowFile, name: name)

    case show_file do
      nil -> {:error, :not_found}
      show_file -> LiveLightingControl.Repo.delete(show_file)
    end
  end
end
