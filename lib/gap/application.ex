defmodule Gap.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GapWeb.Telemetry,
      Gap.Repo,
      {DNSCluster, query: Application.get_env(:gap, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Gap.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Gap.Finch},
      # Start a worker by calling: Gap.Worker.start_link(arg)
      # {Gap.Worker, arg},
      # Start to serve requests, typically the last entry
      GapWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gap.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GapWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
