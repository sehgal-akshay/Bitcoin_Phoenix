defmodule Initializer do

	@users Enum.to_list(1..7) |> Enum.map(fn i -> i |> Integer.to_string |> String.to_atom end)
	@miners [:m1, :m2, :m3, :m4, :m5, :m6, :m7]
	@target_value "000" <> String.slice(Base.encode16(HashGenerator.hash(:crypto.strong_rand_bytes(20))), 3..63)

	@timeout 7200000
	@timesleep 10000
	def start(args) do
		
		NodeSupervisor.start_link
		ProcessRegistry.start_link
		Cache.start_link

		handle_new_users_miners(@users, @miners)
		# IO.puts "starting to mine"
		# mine()

		if args != nil && length(args) != 0 do

			:timer.sleep @timesleep
			arg = Enum.at(args, 0)
			isMiner = Enum.at(args, 1)
			IO.puts "arg = #{arg}, isMiner=#{isMiner}"
			if arg == nil || isMiner == nil || arg != "create" || (isMiner != "true" && isMiner != "false")  do
				IO.puts "				
				format :
				--------
				1. mix run mix.exs
				2. mix run mix.exs create true | mix run mix.exs create false
						"
				System.halt()
			else
				createNode(isMiner)
			end
		end
		:timer.sleep @timeout
	end

	def handle_new_users_miners(users, miners) do 
		
		if miners != nil do
			minersMap = startminers(miners)
			ProcessRegistry.merge minersMap
			current_miners = Cache.lookup(:miners)
			current_miners = if current_miners == :undefined do [] else current_miners end
			Cache.store(:miners, Enum.concat(current_miners, miners))
		end
		if users != nil do 
			usersMap = startusers(users)
			ProcessRegistry.merge usersMap
			SysConfigs.generateInitialWalletBalance(users)
			listen_at_user_nodes(users)
			current_users = Cache.lookup(:users)
			current_users = if current_users == :undefined do [] else current_users end
			Cache.store(:users, Enum.concat(current_users ,users))
		end

	end

	def startusers(users) do
		
		usersMap = Enum.reduce(users, %{}, fn user, acc -> 
		    {generated_private_key, generated_public_key} = DigitalSignature.gen_key_pair()
			res = NodeSupervisor.start_node(user, @target_value, 
									generated_private_key, generated_public_key, false)
			Map.put acc, elem(res ,1), user
		end)
		IO.puts "All nodes have started."
		usersMap
	end

	def startminers(miners) do
		
		Enum.reduce(miners, %{}, fn miner, acc -> 
			{generated_private_key, generated_public_key} = DigitalSignature.gen_key_pair()
			res = NodeSupervisor.start_node(miner, @target_value,
									 generated_private_key, generated_public_key, true)
			Map.put acc, elem(res ,1), miner
		end)
	end

	def mine do
		
		IO.puts "Miners are starting to mine now ....."
		Enum.each(get_miners(), fn miner -> 
			NodeCoordinator.mine(miner)
		end)
	end

	def listen_at_user_nodes(users) do
		
		Enum.each(users, fn user -> 
			NodeCoordinator.listen_at_user_node(user, nil)
		end)
	end

	#The registered new node who joins the bitcoin network will ask the other honest node participant for the 
	#active blockchain info which is arrived by more than 51% consensus rule in the network
	defp createNode(isMiner) do

		new_user = :h
		{generated_private_key, generated_public_key} = DigitalSignature.gen_key_pair()
		res = NodeSupervisor.start_node(new_user, @target_value, 
									generated_private_key, generated_public_key, isMiner)
		ProcessRegistry.register_name(elem(res ,1), new_user)
		NodeCoordinator.new_user_registration(new_user)
	end

	def eq do
		block =  Block.new(1, "asdf", nil, "", "3434")
		block2 = Block.new(1, "asdf", nil, "", "3434")
		if block.index == block2.index do
			true
		else
			false
		end
	end

	def get_users do
		Cache.lookup(:users)
	end

	def get_miners do
		Cache.lookup(:miners)
	end

end

