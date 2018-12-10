defmodule Initializer do

	@users [:a, :b, :c, :d, :e, :f, :g]
	@miners [:m1, :m2, :m3, :m4, :m5, :m6, :m7]
	@target_value "000" <> String.slice(Base.encode16(HashGenerator.hash(:crypto.strong_rand_bytes(20))), 3..63)

	@timeout 7200000
	@timesleep 10000
	def start(args) do
		
		NodeSupervisor.start_link
		ProcessRegistry.start_link
		nodeMap = startusers(@users)
		minersMap = startminers(@miners)
		ProcessRegistry.merge nodeMap
		ProcessRegistry.merge minersMap
		SysConfigs.init(@users)
		:timer.sleep 3000
		listen_at_user_nodes()
		IO.puts "starting to mine"
		mine()

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


	def startusers(users) do
		
		Enum.reduce(users, %{}, fn user, acc -> 
		    {generated_private_key, generated_public_key} = DigitalSignature.gen_key_pair()
			res = NodeSupervisor.start_node(user, @target_value, 
									generated_private_key, generated_public_key, false)
			Map.put acc, elem(res ,1), user
		end)
	end

	def startminers(miners) do
		
		Enum.reduce(miners, %{}, fn miner, acc -> 
			{generated_private_key, generated_public_key} = DigitalSignature.gen_key_pair()
			res = NodeSupervisor.start_node(miner, @target_value,
									 generated_private_key, generated_public_key, true)
			Map.put acc, elem(res ,1), miner
		end)
	end

	defp mine do
		
		Enum.each(@miners, fn miner -> 
			NodeCoordinator.mine(miner)
		end)
	end

	def listen_at_user_nodes do
		
		Enum.each(@users, fn user -> 
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

end

