defmodule Ecampus.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EcampusWeb.Telemetry,
      Ecampus.Repo,
      {DNSCluster, query: Application.get_env(:ecampus, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ecampus.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ecampus.Finch},
      # Start a worker by calling: Ecampus.Worker.start_link(arg)
      # {Ecampus.Worker, arg},
      # Start to serve requests, typically the last entry
      EcampusWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ecampus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EcampusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
