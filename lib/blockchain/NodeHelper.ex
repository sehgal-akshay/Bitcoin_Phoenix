defmodule NodeHelper do

	#This is a helper for the UI 

	@users [:a, :b, :c, :d, :e, :f, :g]
	@miners [:m1, :m2, :m3, :m4, :m5, :m6, :m7]

	def getPublicKeys do
		
		Enum.reduce(@users, [], fn user, acc -> 

		    public_key = NodeCoordinator.get_public_key user
			Enum.concat acc, [public_key]
		end)
	end


	def get_users do
		
		Enum.map(@users, fn x -> Atom.to_string x end)
	end

	def get_miners do
		
		Enum.map(@miners, fn x -> Atom.to_string x end)
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
end
