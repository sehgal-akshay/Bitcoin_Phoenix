defmodule NodeCoordinator do

	def get_state(nodeN) do
		GenServer.call(nodeN, :get_state)
	end

	def get_blockchain(nodeN) do
		GenServer.call(nodeN, :get_blockchain)
	end

	def get_private_key(nodeN) do
		GenServer.call(nodeN, :get_private_key)
	end

	def get_public_key(nodeN) do
		GenServer.call(nodeN, :get_public_key)
	end

	def get_wallet_balance(nodeN) do
		GenServer.call(nodeN, :get_wallet_balance)
	end

	def get_unconfirmed_transactions(nodeN) do
		GenServer.call(nodeN, :get_unconfirmed_transactions)
	end

	def get_last_block_hash(nodeN) do
		GenServer.call(nodeN, :get_last_block_hash)
	end

	def set_blockchain(nodeN, blockchain) do
		GenServer.cast(nodeN, {:blockchain, blockchain})
	end

	def is_miner(nodeN) do
		GenServer.call(nodeN, :isminer)
	end

	#Removes the unconfirmed_transactions (list) from pool
	def remove_unconfirmed_transactions(nodeN, transactions) do
		GenServer.cast(nodeN, {:remove_unconfirmed_transactions, transactions})
	end

	def add_unconfirmed_transaction(nodeN, transaction) do
		GenServer.cast(nodeN, {:add_unconfirmed_transaction, transaction})
	end

	def set_unconfirmed_transactions(nodeN, unconfirmed_transactions) do
		GenServer.cast(nodeN, {:set_unconfirmed_transactions, unconfirmed_transactions})
	end

	def add_to_wallet_balance(nodeN, amount) do
		GenServer.cast(nodeN, {:add_to_wallet_balance, amount})
	end

	#Will be called when other nodes mine a new block and wants to add the blockchain
	def add_block_to_chain(nodeN, block) do
		GenServer.cast(nodeN, {:add_block_to_chain, block})
	end

	#Will be called when node gets a new block and is found to be invalid, it removes from its chain
	def remove_last_block_from_chain(nodeN) do
		GenServer.cast(nodeN, {:remove_last_block_from_chain})
	end

	def listen_at_user_node(nodeN, prev_last_block) do
		GenServer.cast(nodeN, {:listen_at_user_node, prev_last_block})
	end

	def new_user_registration(nodeN) do
		GenServer.cast(nodeN, {:new_user_registration})
	end

	@timeout 1000000
	def mine(nodeN) do
		GenServer.call(nodeN, :mine, @timeout)
	end
		
end