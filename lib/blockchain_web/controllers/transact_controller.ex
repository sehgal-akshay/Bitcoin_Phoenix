defmodule BlockchainWeb.TransactController do
  use BlockchainWeb, :controller

  def index(conn, %{"user" => user, "users" => users}) do
    render(conn, "transact.html", user: user, users: users)
  end

  def transact(conn, %{"from" => from, "to" => to, "amt" => amt}) do
    render(conn, "transactConfirmation.html", from: from, to: to, amt: amt)
  end
end
