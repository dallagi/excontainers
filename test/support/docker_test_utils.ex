defmodule Support.DockerTestUtils do
  defmacro with_created_container(block) do
    quote do
      {stdout, _exit_code = 0} = System.cmd("docker", ["create", "alpine:20201218", "sleep", "infinity"])
      container_id = String.trim(stdout)
      on_exit(fn -> remove_container(container_id) end)

      unquote(block).(container_id)
    end
  end

  defmacro with_running_container(block) do
    quote do
      {stdout, _exit_code = 0} = System.cmd("docker", ["run", "-d", "--rm", "alpine:20201218", "sleep", "infinity"])
      container_id = String.trim(stdout)

      unquote(block).(container_id)
      on_exit(fn -> remove_container(container_id) end)
    end
  end

  def remove_container(id_or_name), do: System.cmd("docker", ["rm", "-f", id_or_name], stderr_to_stdout: true)
end
