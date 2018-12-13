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

  	nodeN = Enum.at(NodeHelper.get_users, 0)
  	blockchain = NodeHelper.get_blockchain(nodeN)
  	blockchain_length = length(blockchain)
  	data = Cache.lookup(:mine_rate_statistics_data)
  	data = if data == :undefined do [] else data end
  	data = Enum.concat data, [[DateTime.utc_now, blockchain_length]]
    Cache.store(:mine_rate_statistics_data, data)
    render(conn, "statistics.html", data: data)
  end

  def blockchaindetails(conn, _params) do

  	nodeN = Enum.at(NodeHelper.get_users, 0)
  	blockchain = NodeHelper.get_blockchain(nodeN)
    render(conn, "blockchaindetails.html", blockchain: blockchain)
  end

  def startsimulation(conn, _params) do

    	{blockchain, unconfirmed_tx} = NodeHelper.get_pre_data

    	mined_tx = Enum.reduce(blockchain, [], fn block, tx_acc ->
    		if block.transactions != nil do
    			Enum.concat tx_acc, block.transactions
    		else
    		   tx_acc
    		end	
    	end )

      simulation_process = ProcessRegistry.get_pid(:simulation_process)

      if simulation_process != nil do 

          conn
          |> put_flash(:info, "INFO: Simulation is already running.")
          |> render("index.html", unconfirmed_tx: unconfirmed_tx, mined_tx: mined_tx)
      else

        	simulation_pid = spawn(NodeHelper, :run_simulation, [])
          ProcessRegistry.register_name(simulation_pid, :simulation_process)

        	conn
        		|> put_flash(:info, "OK : Simulation has started.
              > Started more users to make 100 users. 
        			> Random users among 100 users will perform random transactions in interval of 30 seconds.
        			> All the 6 miners have started mining.")
            |> render("index.html", unconfirmed_tx: unconfirmed_tx, mined_tx: mined_tx)
      end
  end

   def stopsimulation(conn, _params) do

      {blockchain, unconfirmed_tx} = NodeHelper.get_pre_data

      mined_tx = Enum.reduce(blockchain, [], fn block, tx_acc ->
        if block.transactions != nil do
          Enum.concat tx_acc, block.transactions
        else
           tx_acc
        end 
      end )

      simulation_process = ProcessRegistry.get_pid(:simulation_process)

      if simulation_process == nil do 

          conn
          |> put_flash(:info, "INFO: Simulation is already not running.")
          |> render("index.html", unconfirmed_tx: unconfirmed_tx, mined_tx: mined_tx)
      else
          Process.exit(simulation_process, :ok)
          conn
            |> put_flash(:info, "OK : Simulation has stopped")
            |> render("index.html", unconfirmed_tx: unconfirmed_tx, mined_tx: mined_tx)
      end
  end

end
