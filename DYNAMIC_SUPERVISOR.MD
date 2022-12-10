```elixir
supervisor_room_online.ex (supervisor)
defmodule Ln.Room.Supervisor.RoomOnline do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(arg) do
    IO.inspect(arg)

    children = [
      {Registry, keys: :unique, name: Ln.RoomRegistry},
      {PartitionSupervisor,
       child_spec: DynamicSupervisor, name: Ln.RoomDynamicSupervisor, partitions: 4}
    ]

    # PartitionSupervisor's options
    # https://hexdocs.pm/elixir/main/PartitionSupervisor.html#start_link/1-options

    :observer.start()
    # dbg(arg)

    Supervisor.init(children, strategy: :one_for_one)
  end
end

```


```elixir
room_online.ex (worker)

defmodule Ln.Room.RoomOnline do
  use GenServer, restart: :transient
  require Logger

  def start_supervised(room_id) do
    DynamicSupervisor.start_child(
      {:via, PartitionSupervisor, {Ln.RoomDynamicSupervisor, self()}},
      {__MODULE__, room_id}
    )
  end

  defp via(room_id) do
    {:via, Registry, {Ln.RoomRegistry, room_id}}
  end

  def start_link(room_id) do
    GenServer.start_link(
      __MODULE__,
      room_id,
      name: via(room_id)
    )
  end

  @impl true
  def init(room_id) do
    Logger.info("Starting #{inspect(room_id)}")
    {:ok, %{"room_id" => room_id}}
  end

  @impl true
  def handle_info(room_id, state) do
    # IO.inspect(room_id, label: "init voice")
    {:noreply, state}
  end

  @impl true
  def handle_cast(:raise, room_id) do
    raise RuntimeError, message: "Error, Server #{room_id} has crashed"
  end

  @impl true
  def handle_cast({:add, name}, state) do
    {:noreply, Map.put(state, "name", name)}
  end

  @impl true
  def handle_call(:get,_from, state) do
    {:reply, state,state}
  end

  @impl true
  def terminate(reason, room_id) do
    Logger.info("Exiting worker: #{room_id} with reason: #{inspect(reason)}")
  end

  def add_name(room_id, name) do
    GenServer.cast(via(room_id), {:add, name})
  end

  def get(room_id) do
    GenServer.call(via(room_id),:get)
  end

  def stop(room_id) do
    GenServer.stop(via(room_id))
  end

  def crash(room_id) do
    GenServer.cast(via(room_id), :raise)
  end

  def count do
    DynamicSupervisor.count_children(Ln.RoomDynamicSupervisor)
  end
end
```
