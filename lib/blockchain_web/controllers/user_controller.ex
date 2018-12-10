defmodule BlockchainWeb.UserController do
  use BlockchainWeb, :controller

  def index(conn, _params) do
    users = NodeHelper.getUsers()
    render(conn, "user.html", users: users)
  end

  def balance(conn, %{"user" => user}) do
  		nodeN = String.to_atom(user)
  		user_balance = NodeHelper.getBalance(nodeN)
		render(conn, "balance.html", balance: user_balance)  
  end
end
