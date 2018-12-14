defmodule Blockchain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      # Blockchain.Repo,
      # Start the endpoint when the application starts
      BlockchainWeb.Endpoint
      # Starts a worker by calling: Blockchain.Worker.start_link(arg)
       #{Blockchain.Worker, arg},
    ]

    # Task.start(fn -> :timer.sleep(1000); IO.puts("done sleeping") end)
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blockchain.Supervisor]
    Supervisor.start_link(children, opts)

    BlockChainApp.start(nil, nil)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BlockchainWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
