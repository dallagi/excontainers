defmodule Excontainers.ResourcesReaper do
  @moduledoc """
  GenServer to start and communicate with Ryuk, a resources reaper for docker.
  As soon as the socket with Ryuk closes, after some timeout, Ryuk will delete all containers that match the given filters.
  """

  use GenServer

  alias Docker.BindMount
  alias Excontainers.Container

  @ryuk_port 8080

  @ryuk Docker.Container.new("testcontainers/ryuk:0.3.1",
          exposed_ports: [@ryuk_port],
          privileged: true,
          bind_mounts: [
            %BindMount{host_src: "/var/run/docker.sock", container_dest: "/var/run/docker.sock", options: "rw"}
          ]
        )

  defstruct [:ryuk_pid, :socket]

  # CLIENT

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, nil, name: Keyword.get(options, :name, __MODULE__))
  end

  def register(pid \\ __MODULE__, filter), do: GenServer.cast(pid, {:register, filter})

  # CALLBACKS

  @impl true
  def init(_opts) do
    Process.flag(:trap_exit, true)

    {:ok, ryuk_pid} = start_ryuk()
    {:ok, socket} = connect(ryuk_pid)

    {:ok, %__MODULE__{ryuk_pid: ryuk_pid, socket: socket}}
  end

  @impl true
  def handle_cast({:register, filter}, state) do
    spawn(fn -> do_register(state.socket, filter) end)
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    :gen_tcp.close(state.socket)
  end

  defp do_register(socket, {filter_key, filter_value}) do
    :gen_tcp.send(socket, docker_filter(filter_key, filter_value) <> "\n")
    wait_for_ack(socket)
    :ok
  end

  defp connect(ryuk_pid) do
    opts = [:binary, active: false, packet: :line]
    ryuk_port = Container.mapped_port(ryuk_pid, @ryuk_port)

    :gen_tcp.connect(~c"localhost", ryuk_port, opts)
  end

  defp start_ryuk do
    {:ok, ryuk_pid} = Container.start_link(@ryuk)
    {:ok, ryuk_pid}
  end

  defp docker_filter(key, value), do: "#{url_encode(key)}=#{url_encode(value)}"

  defp url_encode(string), do: :uri_string.quote(string)

  defp wait_for_ack(socket), do: {:ok, "ACK\n"} = :gen_tcp.recv(socket, 0, 1_000)
end
