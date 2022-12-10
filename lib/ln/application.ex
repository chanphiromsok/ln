defmodule Ln.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LnWeb.Telemetry,
      # Start the Ecto repository
      # Ln.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ln.PubSub},
      # Start Finch
      {Finch, name: Ln.Finch},
      # Start the Endpoint (http/https)
      LnWeb.Endpoint
      # Start a worker by calling: Ln.Worker.start_link(arg)
      # {Ln.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ln.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LnWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
