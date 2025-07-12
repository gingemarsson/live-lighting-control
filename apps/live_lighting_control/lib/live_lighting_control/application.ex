defmodule LiveLightingControl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveLightingControl.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:live_lighting_control, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:live_lighting_control, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveLightingControl.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LiveLightingControl.Finch},
      # Start a worker by calling: LiveLightingControl.Worker.start_link(arg)
      # {LiveLightingControl.Worker, arg}
      {LiveLightingControl.SceneManager, name: SceneManager},
      {LiveLightingControl.FixtureManager, name: FixtureManager},
      {LiveLightingControl.ProgrammerManager, name: ProgrammerManager},
      {LiveLightingControl.OutputBroadcaster, name: OutputBroadcaster},
      {LiveLightingControl.SACNSender, name: SACNSender},
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: LiveLightingControl.Supervisor)
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
