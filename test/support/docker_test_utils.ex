defmodule Support.DockerTestUtils do
  @moduledoc """
  Helper utils for tests that test integration with Docker.
  """

  @sample_image "alpine:20201218"

  defmacro create_a_container() do
    quote do
      {stdout, _exit_code = 0} = System.cmd("docker", ["create", unquote(@sample_image), "sleep", "infinity"])
      container_id = String.trim(stdout)

      on_exit(fn -> remove_container(container_id) end)

      container_id
    end
  end

  defmacro run_a_container(image \\ @sample_image, command \\ ["sleep", "infinity"], exposed_port \\ nil) do
    quote do
      port_options = if unquote(exposed_port), do: ["-p", unquote(exposed_port)], else: []

      {stdout, _exit_code = 0} =
        System.cmd("docker", ["run"] ++ port_options ++ ["-d", "--rm", unquote(image)] ++ unquote(command))

      container_id = String.trim(stdout)
      on_exit(fn -> remove_container(container_id) end)

      container_id
    end
  end

  def remove_container(id_or_name), do: System.cmd("docker", ["rm", "-f", id_or_name], stderr_to_stdout: true)

  def container_running?(container_id) do
    {running_containers_output, _exit_code = 0} = System.cmd("docker", ["ps", "-f", "id=#{container_id}"])
    running_containers_output =~ short_id(container_id)
  end

  def container_exists?(container_id) do
    {all_containers, _exit_code = 0} = System.cmd("docker", ~w(ps -a))
    all_containers =~ short_id(container_id)
  end

  def image_exists?(image_name) do
    {stdout, _exit_code = 0} = System.cmd("docker", ["images", "-q", image_name])

    stdout != ""
  end

  def pull_image(image_name), do: System.cmd("docker", ["pull", image_name], stderr_to_stdout: true)

  def remove_image(image_name), do: System.cmd("docker", ["rmi", image_name], stderr_to_stdout: true)

  def short_id(docker_id), do: String.slice(docker_id, 1..11)
end
