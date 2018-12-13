defmodule BlockchainWeb.TransactController do
  use BlockchainWeb, :controller

  def index(conn, %{"user" => user, "users" => users}) do
    render(conn, "transact.html", user: user, users: users)
  end

  def transact(conn, %{"from" => from, "to" => to, "amt" => amt}) do
    nodeN = String.to_atom(from)
    to_node = String.to_atom(to)
    user_balance = NodeHelper.get_balance(nodeN)
    users = NodeHelper.get_users_asstring()

    if user_balance < String.to_integer(amt) do
      conn
      |> put_flash(:error, "ERROR : Your balance is too low. Current Balance : #{user_balance}")
      |> render("transact.html", user: from, users: users)
    else
      NodeHelper.perform_transaction(nodeN, to_node, String.to_integer(amt))
      :timer.sleep(2000)
      new_balance = NodeHelper.get_balance(nodeN)

      conn
      |> put_flash(:info, "OK : Transaction successful. Your new balance is : #{new_balance}")
      |> render("transact.html", user: from, users: users)
    end
  end
end
