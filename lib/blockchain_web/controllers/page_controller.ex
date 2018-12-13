defmodule BlockchainWeb.PageController do
  use BlockchainWeb, :controller

  def index(conn, _params) do

  	{blockchain, unconfirmed_tx} = NodeHelper.get_pre_data

  	mined_tx = Enum.reduce(blockchain, [], fn block, tx_acc ->
  		if block.transactions != nil do
  			Enum.concat tx_acc, block.transactions
  		else
  		   tx_acc
  		end	
  	end )
    render(conn, "index.html", unconfirmed_tx: unconfirmed_tx, mined_tx: mined_tx)
  end

  def statistics(conn, _params) do

  	nodeN = String.to_atom(Enum.at(NodeHelper.get_users, 0))
  	blockchain = NodeHelper.get_blockchain(nodeN)
  	blockchain_length = length(blockchain)
  	data = Cache.lookup(:mine_rate_statistics_data)
  	data = if data == :undefined do [] else data end
  	data = Enum.concat data, [[DateTime.utc_now, blockchain_length]]
    Cache.store(:mine_rate_statistics_data, data)
    render(conn, "statistics.html", data: data)
  end

  def blockchaindetails(conn, _params) do

  	nodeN = String.to_atom(Enum.at(NodeHelper.get_users, 0))
  	blockchain = NodeHelper.get_blockchain(nodeN)
    render(conn, "blockchaindetails.html", blockchain: blockchain)
  end

end
