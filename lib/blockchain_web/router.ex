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
    get("/user", UserController, :index)
    get("/miner", MinerController, :index)
    get("/user/balance/:user", UserController, :balance)
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlockchainWeb do
  #   pipe_through :api
  # end
end
