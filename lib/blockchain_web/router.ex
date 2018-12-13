defmodule BlockchainWeb.Router do
  use BlockchainWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BlockchainWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/blockchaindetails", PageController, :blockchaindetails)
    get("/statistics", PageController, :statistics)
    get("/startsimulation", PageController, :startsimulation)
    get("/stopsimulation", PageController, :stopsimulation)
    get("/user", UserController, :index)
    get("/miner", MinerController, :index)
    get("/user/balance/:user", UserController, :get_balance)
    get("/miner/balance/:miner", MinerController, :get_balance)
    get("/miner/startMine/:miner", MinerController, :start_mine)
    get("/miner/stopMine/:miner", MinerController, :stop_mine)
    get("/miner/blockchain/:miner", MinerController, :get_blockchain)
    get("/user/transact/:user/:users", TransactController, :index)
    get("/user/transact/:from/:to/:amt", TransactController, :transact)
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlockchainWeb do
  #   pipe_through :api
  # end
end
