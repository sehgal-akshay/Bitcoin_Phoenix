defmodule BlockchainWeb.UserController do
  use BlockchainWeb, :controller

  def index(conn, _params) do
    users = NodeHelper.get_users_asstring()
    render(conn, "user.html", users: users)
  end

  def get_balance(conn, %{"user" => user}) do
    nodeN = String.to_atom(user)
    user_balance = NodeHelper.get_balance(nodeN)
    render(conn, "balance.html", balance: user_balance)
  end
end
