defmodule Docker.Api.HackneyHost do
  @moduledoc false

  def from_docker_host("tcp://" <> tcp_host), do: "http://" <> tcp_host
  def from_docker_host("unix://" <> socket_path), do: "http+unix://" <> url_encode(socket_path)

  defp url_encode(string), do: :uri_string.quote(string)
end
