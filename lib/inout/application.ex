defmodule Inout.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
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
      # Start a worker by calling: Inout.Worker.start_link(arg)
      # {Inout.Worker, arg},
      # Start to serve requests, typically the last entry
      InoutWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Inout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InoutWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
