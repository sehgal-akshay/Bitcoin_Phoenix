defmodule SysConfigs do
	
	def simulate(users) do
		SysConfigs.begin_transaction(users)
	end

	@doc "nodeMap is used to pick a random node for conducting the transaction"
	def begin_transaction(users) do
		generateInitialWalletBalance(users)
		Enum.each 1..100, fn _ ->
			from = Enum.random(users)
			to = Enum.random(users)
			if from != :undefined && to != :undefined do
				amount = :rand.uniform(100)
				reward = :rand.uniform(5)
				transaction = Transaction.new(from, to, nil, nil, amount, nil, nil, reward)
				transaction = sign_and_embed(from, transaction)
				NodeSupervisor.broadcast(&NodeCoordinator.add_unconfirmed_transaction/2, transaction)
			end
		end
		IO.puts "Added 100 transactions"
		:timer.sleep 30000
		begin_transaction(users)
	end

	#"signs the transaction using sender's private_key and embeds the digital signature in the transaction"
	defp sign_and_embed(sender, transaction) do
		
		sender_private_key = NodeCoordinator.get_private_key(sender)
		sender_public_key = NodeCoordinator.get_public_key(sender)
		msg = Transaction.hash_transaction(transaction)
		digital_signature = DigitalSignature.sign(msg, sender_private_key)
		transaction = Map.put(transaction, :digital_signature, digital_signature)
		transaction = Map.put(transaction, :public_key, sender_public_key)
		transaction
	end

	def generateInitialWalletBalance(users) do
		
		Enum.each users, fn user -> 
			{priv, pub} = DigitalSignature.gen_key_pair()
			initial_transaction = Transaction.new(:dealer, user, nil, nil, 10000, nil, nil, :rand.uniform(5))
			msg= Transaction.hash_transaction(initial_transaction)
			digital_signature = DigitalSignature.sign(msg, priv)
			initial_transaction = Map.put(initial_transaction, :digital_signature, digital_signature)
			initial_transaction = Map.put(initial_transaction, :public_key, pub)
			NodeSupervisor.broadcast(&NodeCoordinator.add_unconfirmed_transaction/2, initial_transaction)
		end
		# Process.exit(self(), :ok)
	end

	def performTransaction(from, to, amount) do
		
		reward = :rand.uniform(5)
		transaction = Transaction.new(from, to, nil, nil, amount, nil, nil, reward)
		transaction = sign_and_embed(from, transaction)
		NodeSupervisor.broadcast(&NodeCoordinator.add_unconfirmed_transaction/2, transaction)
	end

end