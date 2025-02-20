defmodule Inout.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      InoutWeb.Telemetry,
      Inout.Repo,
      {DNSCluster, query: Application.get_env(:inout, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Inout.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Inout.Finch},
      # Start the Inout.Server GenServer
      Inout.Server,
      # Start to serve requests, typically the last entry
      InoutWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Inout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    InoutWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
