defmodule Cache do

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :cache)
  end

  def init(nil) do
    {:ok, %{}}
  end

  def handle_call({:lookup, key}, _from, cache) do
    {:reply, Map.get(cache, key, :undefined), cache}
  end

  def handle_call({:store, key, value}, _from, cache) do
    cache = Map.put(cache, key, value)
    {:reply, cache, cache}
  end

  def lookup(key) do
    GenServer.call(:cache, {:lookup, key})
  end

   def store(key, value) do
    GenServer.call(:cache, {:store, key, value})
  end

end