defmodule Excontainers.Container do
  def new(image, opts \\ [cmd: nil]) do
    %Docker.ContainerConfig{image: image, cmd: opts[:cmd]}
  end
end
