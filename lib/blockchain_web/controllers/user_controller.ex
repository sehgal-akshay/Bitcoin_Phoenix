defmodule BlockchainWeb.UserController do
  use BlockchainWeb, :controller

  def index(conn, _params) do
    render(conn, "second_page.html")
  end
end