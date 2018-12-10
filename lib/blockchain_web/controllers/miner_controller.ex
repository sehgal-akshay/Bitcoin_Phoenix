defmodule BlockchainWeb.MinerController do
  use BlockchainWeb, :controller

  def index(conn, _params) do
    miners = NodeHelper.getMiners()
    render(conn, "miner.html", miners: miners)
  end
end
