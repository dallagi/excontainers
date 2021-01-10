defmodule Docker.BindMount do
  defstruct [:host_src, :container_dest, options: "ro"]

  def new(host_src, container_dest, options) do
    %__MODULE__{host_src: host_src, container_dest: container_dest, options: options}
  end
end
