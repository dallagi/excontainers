defmodule Excontainers.Images do
  def pull(name) do
    name
    |> with_latest_tag_by_default
    |> Docker.Api.pull_image()
  end

  def with_latest_tag_by_default(name) do
    case String.contains?(name, ":") do
      true -> name
      false -> "#{name}:latest"
    end
  end
end
