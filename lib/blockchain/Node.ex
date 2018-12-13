defmodule Node do
	use GenServer

	@mining_reward 100

	def start_link(name \\ nil, target_value \\ 0000000000000000, private_key \\ nil, public_key \\ nil, isMiner \\ :false) do
		GenServer.start_link(__MODULE__, [target_value, private_key, public_key, isMiner], [name: name])
	end

	def init([target_value, private_key, public_key, isMiner]) do
		# IO.puts "Node is starting"
		state = %{:blockchain => [], :unconfirmed_transactions => [], :target_value => target_value, :private_key => private_key, :public_key => public_key, :isMiner => isMiner, :wallet => 10000}
    	{:ok, state}
	end

	def handle_call(:get_state, _, state) do
	    {:reply, state, state}
	end

	def handle_call(:get_private_key, _, state) do
	    {:reply, Map.get(state, :private_key), state}
	end

	def handle_call(:get_public_key, _, state) do
	    {:reply, Map.get(state, :public_key), state}
	end

	def handle_call(:get_wallet_balance, _, state) do
	    {:reply, Map.get(state, :wallet), state}
	end

	def handle_call(:get_last_block_hash, _, state) do
	   	blockchain = Map.get(state, :blockchain)
	   	last_block =
	   		if blockchain != nil do
	   			 last_block = Enum.at(blockchain, -1)
	   			 if last_block != nil do
	   			 	Block.hash_block(last_block)
	   			 else
	   			 	nil
	   			 end
	   		else
	   			nil
	   		end
	    {:reply, last_block, state}
	end

	def handle_call(:isminer, _, state) do
	    {:reply, Map.get(state, :isMiner), state}
	end

	def handle_call(:get_blockchain, _, state) do
		blockchain = Map.get(state, :blockchain)
	    {:reply, blockchain, state}
	end

	def handle_call(:get_miner, _, state) do
		blockchain = Map.get(state, :miner)
	    {:reply, blockchain, state}
	end

	def handle_call(:get_unconfirmed_transactions, _, state) do
		unconfirmed_transactions = Map.get(state, :unconfirmed_transactions)
	    {:reply, unconfirmed_transactions, state}
	end

	def handle_call(:mine, _, state) do
		isMiner = Map.get(state, :isMiner)
		nodeN = ProcessRegistry.lookup(self())
		mining_process =
			if isMiner == true do
				spawn(Node, :mine, [nodeN])
			else
				IO.puts "Cannot mine at this node #{nodeN}. It is not a miner."
				nil
			end
		{:reply, mining_process, state}
	end

	@doc "The user nodes on getting a new block will get the notification and will update their wallet balance"
	def handle_cast({:listen_at_user_node, prev_last_block}, state) do

		nodeN = ProcessRegistry.lookup(self())
		blockchain = Map.get(state, :blockchain)
		last_block = Enum.at(blockchain, -1)
		new_state =
			if last_block != nil && last_block != prev_last_block && last_block.transactions != nil do
				Enum.reduce(last_block.transactions, state, fn transaction, acc ->
					acc =
						if nodeN == transaction.to do
								current_balance = Map.get(state, :wallet)
								# IO.puts "Node #{nodeN} credited amount #{transaction.amount}, balance = #{current_balance}"
								Map.put(acc, :wallet, current_balance+transaction.amount)
						else
								if nodeN == transaction.from do
									current_balance = Map.get(state, :wallet)
									# IO.puts "Node #{nodeN} debited amount #{transaction.amount}, balance = #{current_balance}"
									Map.put(acc, :wallet, current_balance-transaction.amount)
								else
									acc
								end
						end
					acc
				end)
			else
				state
			end
		# IO.puts "Updated amount ====== #{Map.get(new_state, :wallet)}"
		# IO.puts "nodeN ====== #{nodeN}"
		NodeCoordinator.listen_at_user_node(nodeN, last_block)
		{:noreply, new_state}
	end


	#This adds a newly created block to the blockchain. Will be called when some other node has mined
	#and wants to add the newly mined block to the blockchain of the the other nodes
	def handle_cast({:add_block_to_chain, block}, state) do
		blockchain = Map.get(state, :blockchain)
		#Mostly to prevent first block from getting added multiple times on the same chain
		last_block = Enum.at(blockchain, -1)
		new_state =
			if (last_block == nil || (last_block.hash_value != block.hash_value && last_block.transactions != block.transactions && block.transactions != nil)) do
				Map.put(state, :blockchain, Enum.concat(blockchain, [block]))
			else
				state
			end
	    {:noreply, new_state}
	end

	def handle_cast({:remove_last_block_from_chain}, state) do
		blockchain = Map.get(state, :blockchain)
		blockchain_new = Enum.drop(blockchain, -1)
		new_state = Map.put(state, :blockchain, blockchain_new)
	    {:noreply, new_state}
	end

	def handle_cast({:set_blockchain, blockchain}, state) do
		new_state = Map.put(state, :blockchain, blockchain)
	    {:noreply, new_state}
	end

	def handle_cast({:add_to_wallet_balance, amount}, state) do
		current_balance = Map.get(state, :wallet)
		new_state = Map.put(state, :wallet, current_balance+amount)
	    {:noreply, new_state}
	end

	def handle_cast({:set_unconfirmed_transactions, unconfirmed_transactions}, state) do
		new_state = Map.put(state, :unconfirmed_transactions, unconfirmed_transactions)
	    {:noreply, new_state}
	end

	def handle_cast({:add_unconfirmed_transaction, transaction}, state) do
		unconfirmed_transactions = Map.get(state, :unconfirmed_transactions)
		new_state =Map.put(state, :unconfirmed_transactions, Enum.concat(unconfirmed_transactions, [transaction]))
		{:noreply, new_state}
	end

	def handle_cast({:remove_unconfirmed_transactions, transactions}, state) do
		unconfirmed_transactions = Map.get(state, :unconfirmed_transactions)
		new_state = Map.put(state, :unconfirmed_transactions, unconfirmed_transactions--transactions)
		{:noreply, new_state}
	end

	def handle_cast({:set_miner, isMiner}, state) do
		new_state = Map.put(state, :isMiner, isMiner)
	    {:noreply, new_state}
	end

	def handle_cast({:new_user_registration}, state) do
		#1. Get the block chain length from all the other honest node participants including miners
		#2. Arrive at the longest chain with more than 51% consensus
		IO.puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>New user registerd. Node :h joined."
		nodeN = ProcessRegistry.lookup(self())
		participants = ProcessRegistry.get_p_names()
		participants = participants -- [nodeN]
		last_block_with_participants = Enum.reduce(participants, %{}, fn participant,acc ->
					last_block_hash = NodeCoordinator.get_last_block_hash(participant)
					count_nodename = Map.get(acc, last_block_hash)
					if count_nodename != nil do
						{count, nodename} = count_nodename
						Map.put(acc, last_block_hash, {count+1, nodename})
					else
						Map.put(acc, last_block_hash, {1, participant})
					end
		end)
		{max, max_participant}=
			Enum.reduce(Map.values(last_block_with_participants), {0, nil}, fn item, {max, maxp} ->
				{count, participant} = item
				if count > max do
					{count, participant}
				else
					{max, maxp}
				end
		end)
		#Check 51% consensus rule
		new_state =
			if max_participant == nil || max > length(participants)/2 do

				blockchain_honest = NodeCoordinator.get_blockchain(max_participant)
				Map.put(state, :blockchain, blockchain_honest)
			else
				state
			end


		IO.puts(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>max == #{max}, blockchain_honest_length_acquired == #{length(Map.get(new_state, :blockchain))}")

		if Map.get(new_state, :blockchain) == nil || Enum.empty?Map.get(new_state, :blockchain) do
			IO.puts "Newly registered user could not acquire blockchain"
			NodeCoordinator.new_user_registration(nodeN)
		end
		{:noreply, new_state}
	end


	def mine(nodeN) do
		state = NodeCoordinator.get_state(nodeN)
		blockchain = Map.get(state, :blockchain)
		last_block = Enum.at(blockchain, -1)
		{state, last_block} =
			if last_block == nil do
				#First Block
				first_block = Block.new(1, "00000000000000000", "00000000000000000", nil, nil)
				blockchain = [first_block]
				state = Map.put(state, :blockchain, blockchain)
				NodeSupervisor.broadcast(&NodeCoordinator.add_block_to_chain/2, first_block)
				{state, first_block}
			else
				{state, last_block}
			end

		#This node will try to build on top of this hash value
		#New block construction begins
		index = last_block.index + 1
		nonce = :rand.uniform(100000)
		transactions = filter_valid_transactions(nodeN, 10, blockchain)
		#There are no unconfirmed transactions in the pool
		if transactions == nil || Enum.empty?transactions do
			mine(nodeN)
		else
			mined_block = mine_for_hash(state, nodeN, last_block, index, transactions, nonce)
			#We broadcast the newly added block to all the nodes
			NodeSupervisor.broadcast(&NodeCoordinator.add_block_to_chain/2, mined_block)
			#This is compulsory, the blockchain of current node also would have been modified
			state = NodeCoordinator.get_state(nodeN)
			wallet_balance = NodeCoordinator.get_wallet_balance(nodeN)
			IO.puts "##### Blockchain size at node #{nodeN} = #{inspect length(Map.get(state, :blockchain))}, miner_wallet_balance == #{wallet_balance}"
			mine(nodeN)
		end
	end

	defp mine_for_hash(state, nodeN, last_block, index, transactions, nonce) do

		target_value = Map.get(state, :target_value)

		#Update to latest state
		state = NodeCoordinator.get_state(nodeN)

		#While you are mining, your blockchain may get longer because somebody else would have mined
		#_updated is used for block that would have been mined by some other miner and added to this blockchain
		blockchain = Map.get(state, :blockchain)
		last_block_updated = Enum.at(blockchain, -1)

		if last_block_updated != nil && last_block.hash_value != last_block_updated.hash_value do

			# IO.puts("Received ## Blockchain at #{nodeN} == ")
			# printblockchain(blockchain)
			#Received a new block. Check if this valid.
			#1. If valid, start working on top of this new block---
			#--------a. check if index of received block is equal to the one currently working on
			#--------b. check if previous_hash_value of received block is equal to the last one in the chain
			#--------c. hash the received block and check if it is equal to the hash value received
			#2. If invalid, remove from this blockchain, and continue working by using previous block
			test_block = do_hash(Block.new(last_block_updated.index, nil, last_block_updated.prev_block_hash, last_block_updated.transactions, last_block_updated.nonce))
			# IO.puts "
			# index_values = #{last_block_updated.index}, #{index}
			# test_index is #{check(last_block_updated.index,index)}
			# prev_block_hash_values_check = #{last_block_updated.prev_block_hash}, #{last_block.hash_value}
			# test_prev_block_hash is #{check(last_block_updated.prev_block_hash, last_block.hash_value)}
			# test_block hash_value is #{check(test_block.hash_value,last_block_updated.hash_value)}
			# "
			#Below if condition checks if the received block is valid
			if (last_block_updated.index == index
					&& last_block_updated.prev_block_hash == last_block.hash_value
					&& last_block_updated.hash_value == test_block.hash_value) do

				IO.inspect("Node #{nodeN} received a block : valid")
				#Block is valid
				#Update the transactions from the unconfirmed pool and reset nonce
				NodeCoordinator.remove_unconfirmed_transactions(nodeN, last_block_updated.transactions)
				IO.puts "remaining in pool === #{length(NodeCoordinator.get_unconfirmed_transactions(nodeN))}"
				transactions_updated = filter_valid_transactions(nodeN, 10, blockchain)
				nonce_updated = :rand.uniform(100000)
				mine_for_hash(state, nodeN, last_block_updated, last_block_updated.index+1, transactions_updated, nonce_updated)

			else
				IO.inspect("Node #{nodeN} received a block : not valid")
				NodeCoordinator.remove_last_block_from_chain(nodeN)
				#Block is not valid, mine the old block
				mine_for_hash(state, nodeN, last_block, index, transactions, nonce)
			end

		else

			#No new block, continue mining using this info
			block = do_hash(Block.new(index, nil, last_block.hash_value, transactions, nonce))

			# IO.inspect "Mined value at node #{nodeN} is #{inspect block.hash_value}, target_value = #{inspect target_value}"

			if block.hash_value > target_value do
				# :timer.sleep 1000
				mine_for_hash(state, nodeN, last_block, index, transactions, nonce+1)
			else
				IO.puts "##### Mining successful at node #{nodeN}, mined_hash_value = #{inspect block.hash_value}, target_value = #{inspect target_value}"
				NodeCoordinator.remove_unconfirmed_transactions(nodeN, block.transactions)
				#Reward for mining is calculated here
				total_reward = @mining_reward + get_transaction_reward(block.transactions)
				NodeCoordinator.add_to_wallet_balance(nodeN, total_reward)
				#Add balance to the receiver's account
				# add_to_receiver_balance(block.transactions)
				block
			end
		end
	end

	def get_transaction_reward(transactions) do

		Enum.reduce(transactions, 0, fn transaction, sum ->

			sum + transaction.reward
		end)
	end

	defp filter_valid_transactions(nodeN, limit, blockchain) do

		# #We need to use only the valid transactions from here on, remove the invalid ones
		# NodeCoordinator.set_unconfirmed_transactions(nodeN, valid_unconfirmed_transactions)
		unconfirmed_transactions = NodeCoordinator.get_unconfirmed_transactions(nodeN)
		valid_unconfirmed_transactions = Enum.filter(unconfirmed_transactions, fn(transaction) ->
											Transaction.validate(transaction)
											&& validate_transaction_from_blockchain(blockchain, nodeN) end)

		Enum.take(valid_unconfirmed_transactions, limit)


	end


	defp validate_transaction_from_blockchain(blockchain, from) do

			{from_transactions, to_transactions} = Enum.reduce(blockchain, {[], []}, fn block, {from_total_list, to_total_list} ->

					if block.transactions != nil do
							{from_inner, to_inner} = Enum.reduce(block.transactions, {[], []}, fn tx, {from_list, to_list} ->

												from_list =
													if from == tx.from do
														Enum.concat from_list, [tx.amount]
													else
														from_list
													end

												to_list =
													if from == tx.to do
														Enum.concat to_list, [tx.amount]
													else
														to_list
													end

												{from_list, to_list}

											end)
							# IO.puts "from_inner = #{inspect from_inner}"
							# IO.puts "to_inner = #{inspect to_inner}"

							from_total_list = Enum.concat from_total_list, from_inner
							to_total_list = Enum.concat to_total_list, to_inner
							{from_total_list, to_total_list}
					else
						{from_total_list, to_total_list}

					end

				end)

			(Enum.sum(to_transactions) - Enum.sum(from_transactions)) >= 0
	end

	defp do_hash(block) do
		Block.put_hash(block)
	end

end

