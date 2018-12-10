defmodule BlockChainApp do
  use Application

  def start(_type, _args) do
	 
	  args = System.argv
	  Initializer.start(args)
  	  Task.start(fn -> :timer.sleep(1000); IO.puts("done sleeping") end)
  end
end