defmodule Docker.ExecTest do
  use ExUnit.Case, async: true

  import Support.DockerTestUtils

  describe "exec/2" do
    test "starts command inside container and instantly returns exec id" do
      with_running_container(fn container_id ->
        assert {:ok, exec_id} = Docker.Exec.exec(container_id, ["sleep", "1"])

        {:ok, exec_status} = Docker.Exec.inspect_exec(exec_id)
        assert exec_status.running
      end)
    end
  end

  describe "exec_and_wait/2" do
    test "runs command inside container and returns its exit code once it finishes" do
      with_running_container(fn container_id ->
        assert {:ok, {0, ""}} = Docker.Exec.exec_and_wait(container_id, ["sleep", "0.5"])
      end)
    end

    test "when a timeout is set, returns error if command takes too long to finish" do
      with_running_container(fn container_id ->
        assert {:error, :timeout} = Docker.Exec.exec_and_wait(container_id, ["sleep", "0.5"], timeout_ms: 300)
      end)
    end
  end
end
