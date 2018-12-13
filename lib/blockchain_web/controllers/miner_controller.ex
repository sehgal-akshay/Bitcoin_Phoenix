defmodule BlockchainWeb.MinerController do
  use BlockchainWeb, :controller

  def index(conn, _params) do
    miners = NodeHelper.get_miners_asstring()
    render(conn, "miner.html", miners: miners)
  end

  def get_balance(conn, %{"miner" => miner}) do
  		nodeN = String.to_atom(miner)
  		user_balance = NodeHelper.get_balance(nodeN)
		  render(conn, "balance.html", balance: user_balance)  
  end

  def start_mine(conn, %{"miner" => miner}) do
  		nodeN = String.to_atom(miner)
  		miners = NodeHelper.get_miners_asstring()
		  mining_process_pid = ProcessRegistry.get_pid(String.to_atom("mining_process_#{nodeN}"))
  		if mining_process_pid == nil do
  			NodeHelper.start_mine(nodeN)
	  		conn
	  		|> put_flash(:info, "OK : Mining has started")
	  		|> render("miner.html", miners: miners)
	  	else
	  		conn
	  		|> put_flash(:error, "ERROR : You are already mining")
	  		|> render("miner.html", miners: miners)
	  	end  
 end

  def stop_mine(conn, %{"miner" => miner}) do
    	nodeN = String.to_atom(miner)
  		miners = NodeHelper.get_miners_asstring()
  		mining_process_pid = ProcessRegistry.get_pid(String.to_atom("mining_process_#{nodeN}"))
    		IO.inspect(mining_process_pid)
    		if mining_process_pid != nil do
    			NodeHelper.stop_mine(nodeN)
  	  		conn
  	  		|> put_flash(:info, "OK : Mining is stopped")
  	  		|> render("miner.html", miners: miners)
  	  	else
  	  		conn
  	  		|> put_flash(:error, "ERROR : You are currently not mining")
  	  		|> render("miner.html", miners: miners)
  	  	end  
  end

  def get_blockchain(conn, %{"miner" => miner}) do
  		nodeN = String.to_atom(miner)
  		miners = NodeHelper.get_miners_asstring()
  		blockchain = NodeHelper.get_blockchain(nodeN)
  		conn
  		|> render("miner_blockchain.html", miners: miners, 
  			selected_miner: miner,
  			 blockchain: blockchain)
  end
end
