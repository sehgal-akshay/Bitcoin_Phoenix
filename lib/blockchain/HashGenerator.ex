defmodule HashGenerator do
	def hash(hash_string) do
		do_hash(hash_string)
	end	

	def do_hash(hash_string) do
		:crypto.hash(:sha256, hash_string) 
	end
end
# pid = Kernel.inspect self()
# IO.puts String.slice pid, 5..String.length(pid)-2
# IO.puts HashGenerator.hash(3, Kernel.inspect self())
