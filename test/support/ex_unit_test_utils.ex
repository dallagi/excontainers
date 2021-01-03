defmodule Support.ExUnitTestUtils do
  @moduledoc """
  Helper functions for tests that need to test integration with ExUnit.
  """

  defmacro configure_and_reload_on_exit() do
    quote do
      old_opts = ExUnit.configuration()

      ExUnit.configure(autorun: false, seed: 0, colors: [enabled: false], exclude: [:exclude])

      on_exit(fn -> ExUnit.configure(old_opts) end)
    end
  end

  defmacro load_ex_unit do
    quote do
        ExUnit.Server.modules_loaded()
        configure_and_reload_on_exit()
    end
  end
end
