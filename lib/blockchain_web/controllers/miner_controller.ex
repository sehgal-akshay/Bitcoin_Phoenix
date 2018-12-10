defmodule BlockchainWeb.MinerController do
  use BlockchainWeb, :controller

  def index(conn, _params) do
    render(conn, "miner_page.html")
  end
end
