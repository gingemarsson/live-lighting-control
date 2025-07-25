defmodule LiveLightingControlWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveLightingControlWeb.Telemetry,
      # Start a worker by calling: LiveLightingControlWeb.Worker.start_link(arg)
      # {LiveLightingControlWeb.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveLightingControlWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveLightingControlWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveLightingControlWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
