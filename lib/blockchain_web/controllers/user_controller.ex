defmodule BlockchainWeb.UserController do
  use BlockchainWeb, :controller

  def index(conn, _params) do
  	 users = NodeHelper.getUsers
  	 miners = NodeHelper.getMiners
  	 render(conn, "user.html", users: users, miners: miners)
  end
end
