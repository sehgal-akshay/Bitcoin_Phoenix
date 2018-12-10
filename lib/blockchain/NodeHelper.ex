defmodule NodeHelper do

	@users [:a, :b, :c, :d, :e, :f, :g]
	@miners [:m1, :m2, :m3, :m4, :m5, :m6, :m7]

	def getPublicKeys do
		
		Enum.reduce(@users, [], fn user, acc -> 

		    public_key = NodeCoordinator.get_public_key user
			Enum.concat acc, [public_key]
		end)
	end


	def getUsers do
		
		Enum.map(@users, fn x -> Atom.to_string x end)
	end

	def getMiners do
		
		Enum.map(@miners, fn x -> Atom.to_string x end)
	end

	def getBalance(nodeN) do
		NodeCoordinator.get_wallet_balance(nodeN)
	end
end
