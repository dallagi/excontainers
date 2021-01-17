defmodule Docker.BindMount do
  @moduledoc false

  @typedoc """
  A docker bind mount.

  Specifies a directory on the host machine `host_src` to be mounted into the container at path `container_dest`.
  The mode (`"ro"` or `"rw"`) can also be set.
  """
  @type t :: %__MODULE__{
    host_src: String.t(),
    container_dest: String.t(),
    options: String.t()
  }

  defstruct ~w(host_src container_dest options)a

  @doc """
  Creates a new BindMount to mount `host_src` into the container at `container_dest`.

  Options may be `"ro"` for read-only bind mounts, or `"rw"` for read-write ones.
  """
  def new(host_src, container_dest, options \\ "ro") do
    %__MODULE__{host_src: host_src, container_dest: container_dest, options: options}
  end
end
