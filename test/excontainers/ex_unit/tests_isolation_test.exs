defmodule Excontainers.ExUnit.TestsIsolationTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  test "containers are re-created for each test" do
    defmodule SampleTest do
      use ExUnit.Case
      use Excontainers.ExUnit
      alias Excontainers.{Container, Containers}

      container(:alpine, Containers.new("alpine:20201218", cmd: ["sleep", "infinity"]))

      test "a test" do
        IO.puts("<container_id:#{Container.container_id(:alpine)}>")
      end

      test "another test" do
        IO.puts("<container_id:#{Container.container_id(:alpine)}>")
      end
    end

    load_ex_unit()
    run_tests = fn -> assert ExUnit.run() == %{failures: 0, skipped: 0, total: 2, excluded: 0} end

    [first_container_id, second_container_id] =
      capture_io(run_tests)
      |> parse_containers_ids_from_tests_output()

    assert first_container_id != second_container_id
  end

  defp load_ex_unit do
    ExUnit.Server.modules_loaded()
    configure_and_reload_on_exit()
  end

  defp parse_containers_ids_from_tests_output(tests_output) do
    Regex.scan(~r{<container_id:([0-9a-f]+)>}, tests_output)
    |> Enum.map(fn [_matched_substring, container_id] -> container_id end)
  end

  defp configure_and_reload_on_exit() do
    old_opts = ExUnit.configuration()

    ExUnit.configure(autorun: false, seed: 0, colors: [enabled: false], exclude: [:exclude])

    on_exit(fn -> ExUnit.configure(old_opts) end)
  end
end
