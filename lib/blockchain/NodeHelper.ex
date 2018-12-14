defmodule NodeHelper do

	#This is a helper for the UI 

	def getPublicKeys do
		Enum.reduce(get_users(), [], fn user, acc -> 

		    public_key = NodeCoordinator.get_public_key user
			Enum.concat acc, [public_key]
		end)
	end

	def get_users_asstring do
		Enum.map(Initializer.get_users, fn x -> Atom.to_string x end)
	end

	def get_miners_asstring do
		Enum.map(Initializer.get_miners, fn x -> Atom.to_string x end)
	end

	def get_users do
		Initializer.get_users
	end

	def get_miners do
		Initializer.get_miners
	end

	def get_balance(nodeN) do
		NodeCoordinator.get_wallet_balance(nodeN)
	end

	def get_blockchain(nodeN) do
		NodeCoordinator.get_blockchain(nodeN)
	end

	def start_mine(nodeN) do
		mining_process_pid = NodeCoordinator.mine(nodeN)
		ProcessRegistry.register_name(mining_process_pid, String.to_atom("mining_process_#{nodeN}"))
		mining_process_pid
	end

	def stop_mine(nodeN) do
		mining_process_pid = ProcessRegistry.get_pid(String.to_atom("mining_process_#{nodeN}"))
		Process.exit(mining_process_pid, :ok)
		ProcessRegistry.unregister_name(mining_process_pid)
	end

	def perform_transaction(from, to, amount) do 
		SysConfigs.performTransaction(from, to, amount)
	end

	def get_pre_data do
		#Only some miners may be active, so we need the pool where its not there
		{unconfirmed_tx, _} = Enum.reduce(get_miners(), {[],100000000000000000}, fn miner,{acc,l} ->
			uncon_tx = NodeCoordinator.get_unconfirmed_transactions(miner)
			l_uncon_tx = length(uncon_tx)
			if l_uncon_tx < l do
				{uncon_tx, l_uncon_tx}
			else
				{acc, l}
			end
		end)
		nodeN = Enum.at(get_miners(), 0)
		{NodeCoordinator.get_blockchain(nodeN),
		unconfirmed_tx}
	end

	def run_simulation do 
		extra_users = Enum.to_list(8..108) |> Enum.map(fn i -> i |> Integer.to_string |> String.to_atom end)
		Initializer.handle_new_users_miners(extra_users, nil)
		Initializer.mine()
		SysConfigs.simulate(extra_users)
	end

end
