	defmodule NodeSupervisor do

		# This is the supervisor that links the blocks in the nodes
	  	
		use Supervisor

		def start_link() do
			Supervisor.start_link(__MODULE__, [], name: :node_supervisor)
		end
		
		def start_node(name, target_value, private_key, public_key, isMiner) do
			Supervisor.start_child(:node_supervisor, [name, target_value, private_key, public_key, isMiner])
		end

		def init([]) do
			children = [
				worker(Node, [], [restart: :temporary]),
			]
			supervise(children, strategy: :simple_one_for_one)
		end

		#To get a random child from the supervisor
		def get_random_child do

			children = get_children()
			if children != nil && !Enum.empty?children do
				Enum.random children |> Enum.map(fn item -> elem(item, 1) end)
			end
		end

		#Broadcasts by calling the argument function for all the children
		def broadcast(f, args) do
			Enum.each(get_children(), fn node -> f.(elem(node, 1), args) end)
		end

		def get_children do
			
			Supervisor.which_children(:node_supervisor)  
		end

		def get_child_count do
			
			length Supervisor.which_children(:node_supervisor)
		end

		def stop(reason) do
			Supervisor.stop(:node_supervisor, reason)
		end

	end
