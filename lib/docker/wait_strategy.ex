defprotocol Docker.WaitStrategy do
  @spec wait_until_container_is_ready(t, String.t()) :: :ok | {:error, atom()}
  def wait_until_container_is_ready(wait_strategy, id_or_name)
end
