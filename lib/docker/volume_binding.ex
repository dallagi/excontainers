defmodule Docker.VolumeBinding do
  defstruct [:host_src, :container_dest, options: "ro"]
end
