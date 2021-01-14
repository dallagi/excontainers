defmodule Excontainers.ExUnit.TestsIsolationTest do
  use ExUnit.Case

  import Support.DockerTestUtils
  import Support.ExUnitTestUtils
  import ExUnit.CaptureIO

  test "containers are re-created for each test" do
    defmodule SampleTestWithIsolatedContainers do
      use ExUnit.Case
      import Excontainers.ExUnit
      alias Excontainers.Container

      container(:alpine, Docker.Container.new("alpine:20201218", cmd: ["sleep", "infinity"]))

      test "a test", %{alpine: alpine} do
        IO.puts("<container_id:#{Container.container_id(alpine)}>")
      end

      test "another test", %{alpine: alpine} do
        IO.puts("<container_id:#{Container.container_id(alpine)}>")
      end
    end

    load_ex_unit()
    run_tests = fn -> assert ExUnit.run() == %{failures: 0, skipped: 0, total: 2, excluded: 0} end

    [first_container_id, second_container_id] =
      capture_io(run_tests)
      |> parse_containers_ids_from_tests_output()

    assert first_container_id != second_container_id
  end

  test "shared containers are created once for the whole module and then shared by tests" do
    defmodule SampleTestWithSharedContainers do
      use ExUnit.Case
      import Excontainers.ExUnit
      alias Excontainers.Container

      shared_container(:alpine, Docker.Container.new("alpine:20201218", cmd: ["sleep", "infinity"]))

      test "a test", %{alpine: alpine} do
        IO.puts("<container_id:#{Container.container_id(alpine)}>")
      end

      test "another test", %{alpine: alpine} do
        IO.puts("<container_id:#{Container.container_id(alpine)}>")
      end
    end

    load_ex_unit()
    run_tests = fn -> assert ExUnit.run() == %{failures: 0, skipped: 0, total: 2, excluded: 0} end

    [first_container_id, second_container_id] =
      capture_io(run_tests)
      |> parse_containers_ids_from_tests_output()

    assert first_container_id == second_container_id
  end

  test "run_container spawns a container for the test and removes it afterwards" do
    defmodule SampleTestWithSingleContainer do
      use ExUnit.Case
      import Excontainers.ExUnit
      alias Excontainers.Container

      @container Docker.Container.new("alpine:20201218", cmd: ["sleep", "infinity"])

      test "a test" do
        {:ok, pid} = run_container(@container)
        IO.puts(Container.container_id(pid))
      end
    end

    load_ex_unit()
    run_tests = fn -> assert ExUnit.run() == %{failures: 0, skipped: 0, total: 1, excluded: 0} end

    container_id = capture_io(run_tests)

    assert String.length(container_id) > 0
    refute container_running? container_id
  end

  defp parse_containers_ids_from_tests_output(tests_output) do
    Regex.scan(~r{<container_id:([0-9a-f]+)>}, tests_output)
    |> Enum.map(fn [_matched_substring, container_id] -> container_id end)
  end
end
