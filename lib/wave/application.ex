defmodule Wave.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      WaveWeb.Telemetry,
      # Start the Ecto repository
      Wave.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Wave.PubSub},
      # Start Finch
      {Finch, name: Wave.Finch},
      # Start the Endpoint (http/https)
      WaveWeb.Endpoint
      # Start a worker by calling: Wave.Worker.start_link(arg)
      # {Wave.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wave.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WaveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
