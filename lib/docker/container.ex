defmodule Docker.Container do
  @enforce_keys [:image]

  defstruct [
    :image,
    cmd: nil,
    environment: %{},
    exposed_ports: [],
    wait_strategy: nil,
    privileged: false,
    bind_mounts: [],
    labels: %{}
  ]

  defdelegate new(image, opts \\ []), to: Docker.Container.Builder
end
