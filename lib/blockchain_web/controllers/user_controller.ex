defmodule BlockchainWeb.UserController do
  use BlockchainWeb, :controller

  def index(conn, _params) do
    users = NodeHelper.getUsers()
    render(conn, "user.html", users: users)
  end
end
