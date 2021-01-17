defmodule Docker.Images do
  @moduledoc false

  def pull(name) do
    image_name =
      name
      |> with_latest_tag_by_default()

    Docker.Api.Images.pull(image_name)
  end

  defp with_latest_tag_by_default(name) do
    case String.contains?(name, ":") do
      true -> name
      false -> "#{name}:latest"
    end
  end
end
