defmodule ProcessRegistry do
  import Kernel, except: [send: 2]

  use GenServer

  # Client API #
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: :registry)
  end

  def register_name(pid, p_name) when is_pid(pid) do
    GenServer.call(:registry, {:register_name, pid, p_name})
  end

  def unregister_name(pid) do
    GenServer.call(:registry, {:unregister_name, pid})
  end

  def lookup(pid) do
    GenServer.call(:registry, {:lookup, pid})
  end

   def get_pid(p_name) do
    GenServer.call(:registry, {:get_pid, p_name})
  end

  def get_p_names do
    GenServer.call(:registry, {:get_p_names})
  end

  def merge(pid) do
    GenServer.call(:registry, {:merge, pid})
  end

  # Server API #
  def init(nil) do
    {:ok, %{}}
  end

  def handle_call({:unregister_name, pid}, _from, registry) do
    {:reply, pid, deregister(registry, pid)}
  end

  def handle_call({:register_name, pid, p_name}, _from, registry) do
    case Map.get(registry, pid, nil) do
      nil ->
        Process.monitor(pid)
        registry = Map.put(registry, pid, p_name)
        {:reply, :yes, registry}

      _ -> {:reply, :no, registry}
    end
  end

  def handle_call({:merge, nodemap}, _from, registry)do
      registry = Map.merge registry, nodemap
      {:reply, :yes, registry}
  end

  def handle_call({:lookup, pid}, _from, registry) do
    {:reply, Map.get(registry, pid, :undefined), registry}
  end

  def handle_call({:get_p_names}, _from, registry) do
    {:reply, Map.values(registry), registry}
  end

  def handle_call({:get_pid, p_name}, _from, registry) do
    {:reply, getpid(registry, p_name), registry}
  end

  def handle_info({:DOWN, _ref, :process, p_name, _reason}, registry) do
    {:noreply, deregister(registry, p_name)}
  end

  def handle_info(_info, registry), do: {:noreply, registry}

  # Helper Functions #
  defp deregister(registry, pid) when is_pid(pid) do
    Map.delete(registry, pid)
  end

  defp getpid(registry, p_name) do
    result = Enum.find(registry, nil, fn({_pid, cur_p_name}) -> cur_p_name == p_name end)
    if result != nil do
       elem(result, 0)
    else
      result
    end
  end

  defp deregister(registry, p_name) do
    case Enum.find(registry, nil, fn({_pid, cur_p_name}) -> cur_p_name == p_name end) do
      nil -> registry
      {pid, _p_name} -> deregister(registry, pid)
    end
  end

  def terminate(_ \\ 1) do
      # IO.inspect :terminating
      Process.exit self(), :shutdown
  end

end