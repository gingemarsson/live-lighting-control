defmodule LiveLightingControl.Repo do
  use Ecto.Repo,
    otp_app: :live_lighting_control,
    adapter: Ecto.Adapters.SQLite3
end
