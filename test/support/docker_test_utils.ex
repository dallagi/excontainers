defmodule Support.DockerTestUtils do
  defmacro create_a_container() do
    quote do
      {stdout, _exit_code = 0} = System.cmd("docker", ["create", "alpine:20201218", "sleep", "infinity"])
      container_id = String.trim(stdout)

      on_exit(fn -> remove_container(container_id) end)

      container_id
    end
  end

  defmacro run_a_container() do
    quote do
      {stdout, _exit_code = 0} = System.cmd("docker", ["run", "-d", "--rm", "alpine:20201218", "sleep", "infinity"])
      container_id = String.trim(stdout)
      on_exit(fn -> remove_container(container_id) end)

      container_id
    end
  end

  def remove_container(id_or_name), do: System.cmd("docker", ["rm", "-f", id_or_name], stderr_to_stdout: true)

  def image_exists?(image_name) do
    {stdout, _exit_code=0} = System.cmd("docker", ["images", "-q", image_name])

    stdout != ""
  end

  def remove_image(image_name), do: System.cmd("docker", ["rmi", image_name])
end
