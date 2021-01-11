defmodule Docker.Api.Image do
  alias Docker.Api.Client

  @one_minute 60_000

  def pull(image_name) do
    case Tesla.post(Client.plain_text(), "/images/create", "",
           query: %{fromImage: image_name},
           opts: [adapter: [recv_timeout: @one_minute]]
         ) do
      {:ok, %{status: 200}} -> :ok
      {:ok, %{status: status}} -> {:error, {:http_error, status}}
      {:error, message} -> {:error, message}
    end
  end
end
